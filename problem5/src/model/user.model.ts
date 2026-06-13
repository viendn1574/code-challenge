import { Schema, model } from "mongoose";

const userSchema = new Schema(
    {
        name: { type: String, required: true},
        mail: { type: String, required: true},
        dayOfBirth: { type: Date, required: true},
        job: { type: String, required: false}
    },
    { timestamps: true}
);

export const User = model("User", userSchema);
