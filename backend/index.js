import express from 'express'
import cors from 'cors'
import dotenv from 'dotenv'
import ProductRoute from './routes/ProductRoute.js'
import client from 'prom-client'
dotenv.config()

const app = express()
const port = process.env.APP_PORT || 5000

app.use(cors())
app.use(express.json())
app.get('/', (req, res) => {
    res.send('Hello World!')
})
// Support both /api/* and root /* to be compatible with ingress rewrite and direct calls
app.use('/api', ProductRoute)
app.use(ProductRoute)

// Prometheus metrics
const collectDefaultMetrics = client.collectDefaultMetrics
collectDefaultMetrics()

const httpRequestCounter = new client.Counter({
    name: 'http_requests_total',
    help: 'Total number of HTTP requests',
    labelNames: ['method', 'route', 'status']
})

app.use((req, res, next) => {
    const end = res.end
    res.end = function (...args) {
        try {
            httpRequestCounter.labels(req.method, req.route?.path || req.path, String(res.statusCode)).inc()
        } catch (e) {
            // swallow metric errors
        }
        end.apply(this, args)
    }
    next()
})

app.get('/metrics', async (req, res) => {
    try {
        res.set('Content-Type', client.register.contentType)
        res.end(await client.register.metrics())
    } catch (err) {
        res.status(500).send('Error collecting metrics')
    }
})

app.listen(port, () => {
    console.log(`Server listening on port ${port}`)
})

export default app
