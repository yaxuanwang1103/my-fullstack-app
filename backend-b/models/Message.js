import mongoose from "mongoose";

const TodoSchema = new mongoose.Schema(
  {
    author: { type: String, required: true, trim: true, maxlength: 40 },
    text: { type: String, required: true, trim: true, maxlength: 1000 },
    
    // 新增：智能分类字段
    category: { 
      type: String, 
      enum: ['work', 'study', 'life', 'other'], 
      default: 'other' 
    },
    priority: { 
      type: String, 
      enum: ['high', 'normal', 'low'], 
      default: 'normal' 
    },
    deadline: { type: Date },
    tags: [String],
    completed: { type: Boolean, default: false },
    
    // 处理信息
    processedBy: { type: String },
    processedAt: { type: Date },
    
    // 原有字段
    email: { type: String, trim: true, maxlength: 120 },
    ip: { type: String },
    ua: { type: String },
  },
  { timestamps: true }
);

// 索引
TodoSchema.index({ createdAt: -1 });
TodoSchema.index({ category: 1 });
TodoSchema.index({ priority: 1 });

export const Todo = mongoose.model("Todo", TodoSchema);