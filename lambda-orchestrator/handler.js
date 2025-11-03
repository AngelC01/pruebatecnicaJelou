import dotenv from "dotenv";
dotenv.config();

import { createAndConfirmOrder } from "./src/orchestrator.js";

export const orchestrate = async (event) => {
    try {
        const body = typeof event.body === "string" ? JSON.parse(event.body) : event.body;

        const result = await createAndConfirmOrder(body);

        return {
            statusCode: 201,
            body: JSON.stringify(result),
        };
    } catch (err) {
        console.error(err);
        return {
            statusCode: 400,
            body: JSON.stringify({
                success: false,
                message: err.message || "Error in orchestration",
            }),
        };
    }
};
