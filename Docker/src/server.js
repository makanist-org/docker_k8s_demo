const express = require('express');
const promClient = require('prom-client');
const app = express();

// Initialize Prometheus metrics registry
const register = new promClient.Registry();

// Configure default metrics with better naming
promClient.collectDefaultMetrics({
    register,
    prefix: 'nodejs_',
    timeout: 5000,
    labels: {
        app: 'contacts-service',
        environment: process.env.NODE_ENV || 'development'
    }
});

// HTTP request metrics
const httpRequestTotal = new promClient.Counter({
    name: 'nodejs_http_requests_total',
    help: 'Total number of HTTP requests',
    labelNames: ['method', 'path', 'status'],
    registers: [register]
});

const httpRequestDuration = new promClient.Gauge({
    name: 'nodejs_http_request_duration_seconds',
    help: 'Duration of HTTP requests in seconds',
    labelNames: ['method', 'path'],
    registers: [register]
});

// Application startup metric
const appStartTime = new promClient.Gauge({
    name: 'nodejs_app_start_time',
    help: 'Application start timestamp',
    registers: [register]
});
appStartTime.setToCurrentTime();

// Middleware for HTTP metrics
app.use((req, res, next) => {
    const start = Date.now();
    const path = req.route ? req.route.path : req.path;

    res.on('finish', () => {
        const duration = (Date.now() - start) / 1000;
        httpRequestTotal.labels(req.method, path, res.statusCode).inc();
        httpRequestDuration.labels(req.method, path).set(duration);
    });
    next();
});

app.use(function(req, res, next) {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept');
    next();
});

// Hard-Coded for demo
const CONTACTS = [
                    {
                      "name": "Foo Bar",
                      "email": "foobar@test.com",
                      "cell": "000-123-4567"
                    },
                    {
                      "name": "Biz Baz",
                      "email": "bizbaz@test.com",
                      "cell": "000-123-5678"
                    },
                    {
                      "name": "Bing Bang",
                      "email": "bingbang@test.com",
                      "cell": "000-123-6789"
                    },
                    {
                      "name": "Makanist Bang",
                      "email": "bingbang@test.com",
                      "cell": "000-123-1224"
                    }
                ];

app.get('/contacts', (req, res) => {
  res.json({contacts: CONTACTS});
});

// Metrics endpoint
app.get('/metrics', async (req, res) => {
    res.set('Content-Type', register.contentType);
    res.send(await register.metrics());
});

app.listen(3000, () => {
    console.log('Server running on port 3000.');
});