import {Request, Response} from 'express';
import {User} from '../model/user.model';

export async function createUser(req: Request, res: Response) {
    try {
        const { name, mail, dayOfBirth } = req.body;
        if (!name || !mail || !dayOfBirth) {
            return res.status(400).json({ message: "Name, mail, and dayOfBirth are required." });
        }

        const user = await User.create(req.body);
        res.status(201).json(user);
    } catch (error) {
        res.status(400).json({ message: "Error creating user"});
    }
}

type UserFilter = {
    name?: { $regex: string; $options: string };
    job?: { $regex: string; $options: string };
};

export async function getUsers(req: Request, res: Response) {
    try {
        const { name, job, page = 1, limit = 10 } = req.query;

        const filter: UserFilter = {};
        if (typeof name === 'string' && name.trim()) {
            filter.name = { $regex: name.trim(), $options: 'i' };
        }
        if (typeof job === 'string' && job.trim()) {
            filter.job = { $regex: job.trim(), $options: 'i' };
        }

        const pageNumber = Number(page);
        const limitNumber = Number(limit);
        const skip = (pageNumber - 1) * limitNumber;
        
        const [users, total] = await Promise.all([
            User.find(filter)
                .sort({ createdAt: -1 })
                .skip(skip)
                .limit(limitNumber),
            User.countDocuments(filter),
        ]);

        return res.status(200).json({
            data: users,
            meta: {
                total,
                page: pageNumber,
                limit: limitNumber,
                totalPages: Math.ceil(total / limitNumber),
            },
        });
    } catch (err) {
        res.status(500).json({ message: "Error fetching users"});
    }
}

export async function getUserById(req: Request, res: Response) {
    try {
        const user = await User.findById(req.params.id);
        if (!user) return res.status(404).json({message: "User not found."});
        return res.status(200).json(user);
    } catch (err) {
        res.status(500).json({message: "Error fetching user"});
    }
}

export async function updateUser(req: Request, res: Response) {
    try {
        const user = await User.findByIdAndUpdate(req.params.id, req.body, { new: true });
        if (!user) return res.status(404).json({message: "User not found"});
        return res.status(200).json(user);
    } catch (err) {
        res.status(500).json({message: "Error updating user"});
    }
}

export async function deleteUser(req: Request, res: Response) {
    try {
        const user = await User.findByIdAndDelete(req.params.id);
        if (!user) return res.status(404).json({message: "User not found"});
        return res.status(200).json({message: "User deleted successfully", user});
    } catch (err) {
        res.status(500).json({message: "Error deleting user"});
    }
}