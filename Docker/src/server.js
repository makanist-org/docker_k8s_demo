const express = require('express');
const promClient = require('prom-client');
const app = express();

// Initialize default Prometheus metrics collector
const collectDefaultMetrics = promClient.collectDefaultMetrics;
const register = new promClient.Registry();

// Start collecting default metrics with more specific configuration
collectDefaultMetrics({ 
    register,
    prefix: 'nodejs_app_', // Add prefix to differentiate your app metrics
    labels: { // Add custom labels for better filtering
        app: 'contacts-service',
        environment: process.env.NODE_ENV || 'development'
    },
    timeout: 10000,  // Collection interval in ms
    gcDurationBuckets: [0.001, 0.01, 0.1, 1, 2, 5],  // Customize GC duration buckets
});

// Add a basic counter to verify metrics
const startupCounter = new promClient.Counter({
    name: 'nodejs_app_startup_total',
    help: 'Counter that increments on application startup',
    registers: [register]
});

// Increment startup counter
startupCounter.inc();

// Custom metrics
const httpRequestCounter = new promClient.Counter({
    name: 'http_requests_total',
    help: 'Total number of HTTP requests',
    labelNames: ['method', 'path', 'status'],
    registers: [register]
});

const httpRequestDuration = new promClient.Histogram({
    name: 'http_request_duration_seconds',
    help: 'Duration of HTTP requests in seconds',
    labelNames: ['method', 'path'],
    registers: [register]
});

// Middleware to track metrics
app.use((req, res, next) => {
    const start = Date.now();
    res.on('finish', () => {
        const duration = Date.now() - start;
        httpRequestDuration.observe({ method: req.method, path: req.path }, duration / 1000);
        httpRequestCounter.inc({ method: req.method, path: req.path, status: res.statusCode });
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