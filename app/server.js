const express = require('express');
const redis = require('redis');

const app = express();
const port = process.env.PORT || 3000;

// Redis connection
const redisClient = redis.createClient({
  socket: {
    host: process.env.REDIS_HOST || 'localhost',
    port: process.env.REDIS_PORT || 6379
  },
  retry_strategy: function(options) {
    if (options.error && options.error.code === 'ECONNREFUSED') {
      return new Error('Redis connection refused');
    }
    if (options.total_retry_time > 1000 * 60 * 60) {
      return new Error('Retry time exhausted');
    }
    if (options.attempt > 10) {
      return undefined;
    }
    return Math.min(options.attempt * 100, 3000);
  }
});

// Connect to Redis
redisClient.connect().catch(console.error);

// Middleware
app.use(express.json());

// Routes
app.get('/', async (req, res) => {
  try {
    // Increment visitor counter
    const count = await redisClient.incr('visitor_count');
    
    res.send(`
      <!DOCTYPE html>
      <html>
      <head>
        <title>Redis ECS Demo</title>
        <style>
          body {
            font-family: Arial, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            background-color: #f0f0f0;
          }
          .container {
            text-align: center;
            background-color: white;
            padding: 40px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
          }
          h1 { color: #333; }
          .counter { 
            font-size: 48px; 
            color: #e74c3c; 
            margin: 20px 0;
          }
          .info { 
            color: #666; 
            margin-top: 20px;
          }
        </style>
      </head>
      <body>
        <div class="container">
          <h1>🚀 Redis + ECS Demo</h1>
          <p>Welcome! You are visitor number:</p>
          <div class="counter">${count}</div>
          <div class="info">
            <p>Container ID: ${process.env.HOSTNAME || 'unknown'}</p>
            <p>Redis Host: ${process.env.REDIS_HOST || 'localhost'}</p>
          </div>
        </div>
      </body>
      </html>
    `);
  } catch (error) {
    console.error('Redis error:', error);
    res.status(500).json({ error: 'Failed to connect to Redis' });
  }
});

// Health check endpoint
app.get('/health', async (req, res) => {
  try {
    await redisClient.ping();
    res.json({ status: 'healthy', redis: 'connected' });
  } catch (error) {
    res.status(500).json({ status: 'unhealthy', redis: 'disconnected' });
  }
});

// Stats endpoint
app.get('/stats', async (req, res) => {
  try {
    const count = await redisClient.get('visitor_count') || '0';
    const info = await redisClient.info();
    
    res.json({
      visitor_count: parseInt(count),
      redis_info: {
        version: info.match(/redis_version:(.+)/)?.[1],
        connected_clients: info.match(/connected_clients:(\d+)/)?.[1],
        used_memory_human: info.match(/used_memory_human:(.+)/)?.[1]
      }
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to get stats' });
  }
});

// Reset counter endpoint
app.post('/reset', async (req, res) => {
  try {
    await redisClient.set('visitor_count', '0');
    res.json({ message: 'Counter reset successfully' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to reset counter' });
  }
});

// Start server
app.listen(port, () => {
  console.log(`Server running on port ${port}`);
  console.log(`Redis host: ${process.env.REDIS_HOST || 'localhost'}`);
});

// Graceful shutdown
process.on('SIGTERM', async () => {
  console.log('SIGTERM received, shutting down gracefully');
  await redisClient.quit();
  process.exit(0);
});
