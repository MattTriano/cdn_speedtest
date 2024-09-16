function handler (event) {
    const host = event.request.headers.host.value;
    
    if (host.startsWith('www.')) {
        const newHost = host.slice(4);
        
        const qstr = encodeRequestQuery(event.request.querystring);
        const qpart = qstr === '' ? '' : `?${qstr}`;
        
        const location = `https://${newHost}${event.request.uri}${qpart}`;
        
        return {
            statusCode: 301,
            statusDescription: 'Moved Permanently',
            headers: {
                location: {value: location}
            }
        };
    }
    
    return event.request;
}

function encodeRequestQuery (querystring) {
    const parts = [];

    for (const param in querystring) {
        const query = querystring[param];
        
        if (query.multiValue) {
            parts.push(query.multiValue.map((item) => param + '=' + item.value).join('&'));
        } else if (query.value === '') {
            parts.push(param);
        } else {
            parts.push(param + '=' + query.value);
        }
    }

    return parts.join('&');
}
