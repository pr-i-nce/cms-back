import jwt, { SignOptions } from "jsonwebtoken";
import { env } from "../config/env.js";

export type JwtPayload = { sub: string; csrf?: string };

export const signAccessToken = (userId: string, csrf?: string) =>
  jwt.sign({ sub: userId, csrf }, env.jwtAccessSecret, { expiresIn: env.jwtAccessTtl as SignOptions["expiresIn"] });

export const signRefreshToken = (userId: string) =>
  jwt.sign({ sub: userId }, env.jwtRefreshSecret, { expiresIn: env.jwtRefreshTtl as SignOptions["expiresIn"] });

export const verifyAccessToken = (token: string) =>
  jwt.verify(token, env.jwtAccessSecret) as JwtPayload;

export const verifyRefreshToken = (token: string) =>
  jwt.verify(token, env.jwtRefreshSecret) as JwtPayload;
