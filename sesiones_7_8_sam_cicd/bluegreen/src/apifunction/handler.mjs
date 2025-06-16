import serverlessExpress from "@codegenie/serverless-express";
import { app } from "./index.mjs";

let handler = serverlessExpress({ app });

export { handler };
