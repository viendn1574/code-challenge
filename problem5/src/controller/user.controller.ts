import {Request, Response} from 'express';
import {User} from '../model/user.model';

export async function createUser(req: Request, res: Response) {
    try {
        const user = await User.create(req.body);
        res.status(201).json(user);
    } catch (error) {
        res.status(400).json({ message: "Error creating user", error });
    }
}

export async function getUsers(req: Request, res: Response) {
    try {
        const users = await User.find();
        res.status(200).json(users);
    } catch (err) {
        res.status(500).json({ message: "Error fetching users", err});
    }
}

export async function getUserById(req: Request, res: Response) {
    try {
        const user = await User.findById(req.params.id);
        if (!user) return res.status(404).json({message: "User not found."});
        return res.status(200).json(user);
    } catch (err) {
        res.status(500).json({message: "Error fetching user", err});
    }
}

export async function updateUser(req: Request, res: Response) {
    try {
        const user = await User.findByIdAndUpdate(req.params.id, req.body, { new: true });
        if (!user) return res.status(404).json({message: "User not found"});
        return res.status(200).json(user);
    } catch (err) {
        res.status(500).json({message: "Error updating user", err});
    }
}

export async function deleteUser(req: Request, res: Response) {
    try {
        const user = await User.findByIdAndDelete(req.params.id);
        if (!user) return res.status(404).json({message: "User not found"});
        return res.status(200).json({message: "User deleted successfully", user});
    } catch (err) {
        res.status(500).json({message: "Error deleting user", err});
    }
}