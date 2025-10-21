import mongoose from "mongoose";

const MessageSchema = new mongoose.Schema(
  {
    author: { type: String, required: true, trim: true, maxlength: 40 },
    text:   { type: String, required: true, trim: true, maxlength: 1000 },
    email:  { type: String, trim: true, maxlength: 120 }, // 可选
    // 记录一些风控信息（可选）
    ip:     { type: String },
    ua:     { type: String },
  },
  { timestamps: true } // 自动加 createdAt / updatedAt
);

// 常用索引：按创建时间倒序、以及简单全文搜索
MessageSchema.index({ createdAt: -1 });
MessageSchema.index({ author: "text", text: "text" });

export const Message = mongoose.model("Message", MessageSchema);
