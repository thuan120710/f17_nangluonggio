# Changelog - Wind Turbine Job

## Cập nhật mới: Thông báo và Âm thanh

### 🔊 Âm thanh đã thêm

#### Client-side (FiveM Native Sounds):
- **Bắt đầu ca làm việc**: Âm thanh "CHECKPOINT_PERFECT" - Tạo cảm giác tích cực khi bắt đầu
- **Kết thúc ca làm việc**: Âm thanh "QUIT" - Âm thanh thoát nhẹ nhàng
- **Rút tiền**: Âm thanh "PICK_UP" - Âm thanh nhặt tiền
- **Sửa chữa thành công (Perfect)**: Âm thanh "CHECKPOINT_PERFECT" - Âm thanh hoàn hảo
- **Sửa chữa tốt (Good)**: Âm thanh "CHECKPOINT_NORMAL" - Âm thanh bình thường
- **Sửa chữa thất bại (Fail)**: Âm thanh "CHECKPOINT_MISSED" - Âm thanh thất bại
- **Cảnh báo hệ thống**: Âm thanh "CHECKPOINT_MISSED" - Khi hệ thống xuống dưới 30%

#### NUI-side (Web Audio API):
- **Click**: Âm thanh click nhẹ (600Hz, 0.1s) - Khi click vào hệ thống, siết ốc, gạt cầu dao
- **Success**: Âm thanh thành công (800Hz, 0.3s) - Khi hoàn thành minigame hoàn hảo
- **Fail**: Âm thanh thất bại (200Hz, 0.2s) - Khi thất bại trong minigame
- **Repair**: Âm thanh sửa chữa (400Hz, 0.15s) - Khi trét xi măng vào vết nứt

### 📢 Thông báo đã thêm

#### Thông báo trạng thái ca làm việc:
- ✅ **Bắt đầu ca**: "Đã bắt đầu ca làm việc tại cối xay gió!" (success, 3s)
- 👋 **Kết thúc ca**: "Đã kết thúc ca làm việc!" (primary, 3s)

#### Thông báo thu nhập:
- 💵 **Thu nhập thường**: "+$[số tiền]" (primary, 2s) - Khi hiệu suất 50-79%
- 💵 **Thu nhập cao**: "+$[số tiền] | Hiệu suất tuyệt vời!" (success, 2s) - Khi hiệu suất ≥80%
- ⚠️ **Ngừng sinh tiền**: "Cối xay gió ngừng sinh tiền! Cần sửa chữa hệ thống!" (error, 3s)
- 💰 **Rút tiền thành công**: "Đã rút $[số tiền] từ quỹ tiền lương!" (success)
- ❌ **Không có tiền**: "Không có tiền để rút!" (error)

#### Thông báo hệ thống:
- 🔧 **Xuống cấp**: "Các hệ thống đang xuống cấp theo thời gian..." (warning, 2s)
- ⚠️ **Cần bảo trì**: "Chú ý: Hệ thống [TÊN] cần bảo trì!" (warning, 3s) - Khi hệ thống 30-49%
- ⚠️ **Nguy hiểm**: "Cảnh báo: Hệ thống [TÊN] đang ở mức nguy hiểm!" (error, 5s) - Khi hệ thống <30%

#### Thông báo hiệu suất:
- 🚨 **Ngừng hoạt động**: "Cối xay gió đã ngừng hoạt động! Hiệu suất quá thấp!" (error, 5s) - Khi hiệu suất <10%
- ⚠️ **Hiệu suất thấp**: "Hiệu suất rất thấp! Cần sửa chữa ngay!" (error, 3s) - Khi hiệu suất <30%

#### Thông báo kết quả sửa chữa:
- 🌟 **Hoàn hảo**: "Hoàn hảo! Hệ thống [TÊN] đã được sửa chữa tốt!" (success, 3s)
- ✅ **Tốt**: "Tốt! Hệ thống [TÊN] đã được cải thiện!" (success, 3s)
- ❌ **Thất bại**: "Thất bại! Hệ thống [TÊN] bị giảm hiệu suất!" (error, 3s)

#### Thông báo khoảng cách:
- ⚠️ **Rời xa**: "Bạn đang rời xa cối xay gió! Ca làm việc vẫn tiếp tục." (warning, 5s) - Khi cách >50m (thông báo mỗi 30s)

### 🎮 Cải tiến trải nghiệm

1. **Phản hồi tức thì**: Mỗi hành động đều có âm thanh và thông báo phù hợp
2. **Thông tin rõ ràng**: Người chơi luôn biết trạng thái hệ thống và thu nhập
3. **Cảnh báo kịp thời**: Thông báo trước khi hệ thống xuống quá thấp
4. **Động lực làm việc**: Thông báo thu nhập cao khi hiệu suất tốt
5. **Linh hoạt AFK**: Có thể rời xa cối xay gió, ca làm việc vẫn tiếp tục (chỉ cảnh báo)

### 📝 Ghi chú kỹ thuật

- Sử dụng QBCore.Functions.Notify cho thông báo
- Sử dụng FiveM Native Sounds (PlaySound) cho âm thanh client-side
- Sử dụng Web Audio API cho âm thanh NUI-side
- Tất cả thông báo đều có icon emoji để dễ nhận biết
- Thời gian hiển thị thông báo được tối ưu theo mức độ quan trọng

### 🔧 Cấu hình

Không cần cấu hình thêm. Tất cả âm thanh và thông báo đã được tích hợp sẵn.

### 🐛 Lưu ý

- Âm thanh NUI sử dụng Web Audio API, có thể cần quyền autoplay trên một số trình duyệt
- Âm thanh client-side sử dụng native sounds của GTA V, không cần file âm thanh bên ngoài
