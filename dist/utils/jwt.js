import jwt from "jsonwebtoken";
import { env } from "../config/env.js";
export const signAccessToken = (userId, csrf) => jwt.sign({ sub: userId, csrf }, env.jwtAccessSecret, { expiresIn: env.jwtAccessTtl });
export const signRefreshToken = (userId) => jwt.sign({ sub: userId }, env.jwtRefreshSecret, { expiresIn: env.jwtRefreshTtl });
export const verifyAccessToken = (token) => jwt.verify(token, env.jwtAccessSecret);
export const verifyRefreshToken = (token) => jwt.verify(token, env.jwtRefreshSecret);
