const sharp = require("sharp");
const {
  S3Client,
  GetObjectCommand,
  PutObjectCommand,
} = require("@aws-sdk/client-s3");

const client = new S3Client();

exports.handler = async (event) => {
  const bucket = event.Records[0].s3.bucket.name;
  const key = decodeURIComponent(
    event.Records[0].s3.object.key.replace(/\+/g, " "),
  );

  // Skip if the image is already in the resized folder
  if (key.startsWith(process.env.RESIZED_PREFIX)) {
    return;
  }

  try {
    const input = {
      Bucket: bucket,
      Key: key,
    };

    // Get the image from S3
    const command = new GetObjectCommand(input);
    const response = await client.send(command);
    const bytes = await response.Body.transformToByteArray();

    // Resize the image
    const resized = await sharp(bytes)
      .resize(parseInt(process.env.IMAGE_WIDTH), null, {
        withoutEnlargement: true,
        fit: "inside",
      })
      .toBuffer();

    // Generate new key for resized image
    const filename = key.split("/").pop();
    const resizedKey = `${process.env.RESIZED_PREFIX}${filename}`;

    // Upload resized image back to S3

    const output = {
      Bucket: bucket,
      Key: resizedKey,
      Body: resized,
    };
    const command2 = new PutObjectCommand(output);
    const response2 = await client.send(command2);

    return {
      statusCode: 200,
      body: JSON.stringify({
        message: "Image resized successfully",
        source: key,
        destination: resizedKey,
      }),
    };
  } catch (error) {
    console.error("Error processing image:", error);
    throw error;
  }
};
