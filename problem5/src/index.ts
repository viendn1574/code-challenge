import express from 'express';
import routes from './routes/user.route';
import { connectDB } from './config/db';

const app = express();
const PORT = 3000;

app.use(express.urlencoded({ extended: true }));
app.use(express.json());
app.use("/api/users", routes);

app.listen(PORT, async () => {
    await connectDB();
    console.log(`Server is running on port ${PORT}`);
});