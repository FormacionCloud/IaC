#!/usr/bin/env node
import * as cdk from 'aws-cdk-lib';
import { CdkprojectStack } from '../lib/cdkproject-stack';

const app = new cdk.App();
new CdkprojectStack(app, 'CdkprojectStack', {
  env: {
    account: process.env.CDK_DEFAULT_ACCOUNT,
    region: process.env.CDK_DEFAULT_REGION,
  },
});
