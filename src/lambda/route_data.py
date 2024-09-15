import base64
import datetime as dt
import json
import logging
import os
from typing import Any
import urllib.parse

import boto3

MAX_PAYLOAD_SIZE = 10 * (2**20)


def main(event: dict[str, Any], context) -> dict[str, Any]:
    logger = logging.getLogger()
    logger.setLevel(logging.INFO)

    allowed_origins = os.environ["ALLOWED_ORIGINS"].split(",")

    def create_response(status_code: int, body: dict = None) -> dict[str, Any]:
        origin = event.get("headers", {}).get("origin", event.get("headers", {}).get("Origin", ""))
        cors_headers = {
            "Access-Control-Allow-Headers": "Content-Type",
            "Access-Control-Allow-Methods": "OPTIONS,POST",
        }
        if origin in allowed_origins:
            cors_headers["Access-Control-Allow-Origin"] = origin
        response = {
            "statusCode": status_code,
            "headers": cors_headers,
        }
        if body:
            response["body"] = json.dumps(body)
        return response

    if event.get("requestContext", {}).get("http", {}).get("method") == "OPTIONS":
        return create_response(200, {"message": "CORS preflight request successful"})

    try:
        payload_size = len(event["body"])
        if payload_size > MAX_PAYLOAD_SIZE:
            return {
                "statusCode": 413,
                "body": json.dumps(
                    {
                        "message": "Payload too large",
                        "max_size": MAX_PAYLOAD_SIZE,
                        "received_size": payload_size,
                    }
                ),
            }

        isBase64Encoded = event.get("isBase64Encoded", False)
        body = event.get("body", "")

        if isBase64Encoded:
            decoded_body = base64.b64decode(body).decode("utf8")
        else:
            decoded_body = body
        parsed_body = urllib.parse.parse_qs(decoded_body)

        headers = event.get("headers", {})
        request_context = event.get("requestContext", {})
        http = request_context.get("http", {})

        data = {
            "download": parsed_body.get("d", [""])[0],
            "upload": parsed_body.get("u", [""])[0],
            "ping": parsed_body.get("p", [""])[0],
            "jitter": parsed_body.get("jit", [""])[0],
            "user_agent": parsed_body.get("ua", [""])[0],
            "download_size": parsed_body.get("dd", [""])[0],
            "upload_size": parsed_body.get("ud", [""])[0],
            "content_length": headers.get("content-length", None),
            "origin": headers.get("origin", ""),
            "header_user_agent": headers.get("user-agent", ""),
            "x_forwarded_for": headers.get("x-forwarded-for", ""),
            "x_forwarded_port": headers.get("x-forwarded-port", ""),
            "source_ip": http.get("sourceIp", ""),
            "source_user_agent": http.get("userAgent", ""),
            "time_of_test": request_context.get("time", None),
            "epoch_of_test": request_context.get("timeEpoch", None),
            "time_processed": dt.datetime.now().isoformat(),
            "orig_body": body,
            "decoded_body": decoded_body,
            "isBase64Encoded": isBase64Encoded,
        }

        s3 = boto3.client("s3")
        bucket_name = os.environ["OUTPUT_BUCKET"]

        timestamp = dt.datetime.now().strftime("%Y%m%d-%H%M%S")
        date_prefix = timestamp[0:8]
        key = f"{date_prefix}/processed_data_{timestamp}.json"
        s3.put_object(
            Bucket=bucket_name, Key=key, Body=json.dumps(data), ContentType="application/json"
        )
        return create_response(204)
    except Exception as e:
        logger.error(f"An error occurred: {e}")
        logger.error(f"event: {event} (type: {type(event)})")
        logger.error(f"context: {context} (type: {type(context)})")
        return create_response(500, {"message": "Error processing data", "error": str(e)})
