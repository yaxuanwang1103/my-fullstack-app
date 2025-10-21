import mongoose from "mongoose";

export async function connectMongo(uri) {
  mongoose.set("strictQuery", true);
  await mongoose.connect(uri, {
    // 这些参数新版可省，但显式写更清晰
    autoIndex: true,
    serverSelectionTimeoutMS: 10000,
  });
  console.log("✅ Mongo connected");
}
