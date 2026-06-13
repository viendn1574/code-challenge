import mongoose from 'mongoose';

export async function connectDB(): Promise<void> {
    try {
        const mongoUri = process.env.MONGO_URI || 'mongodb://localhost:12345/problem5';
        const conn = await mongoose.connect(mongoUri);
        console.log(`MongoDb connected: ${conn.connection.host}`);
    } catch (err) {
        console.error(`Database connection failed: ${err}`);
        process.exit(1);
    }
}