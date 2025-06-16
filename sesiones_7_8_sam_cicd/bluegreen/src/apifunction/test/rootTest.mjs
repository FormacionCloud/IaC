import { handler } from "../handler.mjs";
import { expect } from "chai";
// Import dynamodb from aws-sdk
//import { DynamoDBDocumentClient, GetCommand } from "@aws-sdk/lib-dynamodb";
//import { mockClient } from "aws-sdk-client-mock";

describe("GET /", () => {
  //const ddbMock = mockClient(DynamoDBDocumentClient);

  beforeEach(() => {
    //ddbMock.reset();
  });

  it("Testear el parémetro 'nombre'", async () => {
    const parametro = "Pedro";

    const event = {
      path: "/",
      httpMethod: "GET",
      multiValueQueryStringParameters: {
        nombre: parametro,
      },
      requestContext: {
        domainName: "http://localhost",
      },
    };

    // Invocar handler
    const result = await handler(event);

    const expectedResult = {
      statusCode: 200,
      body: `Hola mundo!! El parámetro 'nombre' es: ${parametro}`,
    };

    expect(result.statusCode).to.equal(expectedResult.statusCode);
    expect(result.body).to.equal(expectedResult.body);
  });
});
