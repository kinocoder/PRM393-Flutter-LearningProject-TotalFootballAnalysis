# Mảng C — Đội hình (C01–C04)

Đặc tả + thiết kế + kiểm thử cho KAN-43, KAN-48, KAN-53, KAN-58. Cấu trúc code theo slide "Cấu trúc core MVVM của nhóm" (Core Overview v2).

## 1. Màn hình

| Mã | Route | Screen | ViewModel |
|---|---|---|---|
| C01 Danh sách đội hình | `/C01` | `ui/lineups/widgets/c01_screen.dart` (`C01Screen`) | `c01_view_model.dart` (`C01ViewModel`, `lineupSyncProvider`) |
| C02 Chọn sơ đồ | `/C02/:lineupId?next=C04` | `c02_screen.dart` (`C02Screen`) | `c02_view_model.dart` (`C02ViewModel`, `c02StateProvider`) |
| C03 Chọn cầu thủ cho vị trí | `/C03/:lineupId/:slotId` | `c03_screen.dart` (`C03Screen`) | `c03_view_model.dart` (`C03ViewModel`, `c03StateProvider`) |
| C04 Sân đội hình và lưu | `/C04/:lineupId` | `c04_screen.dart` (`C04Screen`) | `c04_view_model.dart` (`c04StateProvider`) |

Bản nháp dùng chung cho C02/C03/C04: `lineup_draft_view_model.dart` (`LineupDraftViewModel`, khoá theo `lineupId`). Mọi thao tác chỉ sửa bản nháp; chỉ nút **Lưu** ở C04 mới ghi xuống repository.

Luồng: `C01 → (tạo) → C02 → C04 ⇄ C03`, `C04 → C02` (đổi sơ đồ rồi quay lại), `C01 → C04` (mở).

## 2. Yêu cầu (SRS)

### C01 — Danh sách đội hình (KAN-43)
- Xem danh sách theo UID, mới sửa trước; mỗi dòng: tên, sơ đồ, số vị trí đã xếp, thời gian sửa.
- Tạo (hỏi tên, mặc định 4-3-3 trống → C02), mở (→ C04), đổi sơ đồ (→ C02 → C04), đổi tên, xoá có xác nhận + **Hoàn tác**.
- Tên: 1–30 ký tự sau khi bỏ khoảng trắng hai đầu.
- Khởi động lại vẫn còn (SQLite). UID khác không thấy đội hình. Chưa đăng nhập → thông báo cần đăng nhập.
- Đồng bộ Firestore chạy nền khi mở màn/kéo làm mới; lỗi chỉ hiện dải cảnh báo, không chặn offline.

### C02 — Chọn sơ đồ (KAN-48)
- Hai sơ đồ MVP, 11 vị trí mỗi sơ đồ:
  - **4-3-3**: GK, LB, LCB, RCB, RB, LCM, CM, RCM, LW, ST, RW
  - **4-4-2**: GK, LB, LCB, RCB, RB, LM, LCM, RCM, RM, LST, RST
- Xem trước vị trí trên sân. Chọn rồi bấm Back → không đổi gì.
- **Quy tắc đổi sơ đồ**: giữ cầu thủ ở slot có cùng ID trong sơ đồ mới; gỡ cầu thủ ở slot không còn. 4-3-3 → 4-4-2 giữ GK, LB, LCB, RCB, RB, LCM, RCM và gỡ CM, LW, ST, RW. Có cầu thủ bị gỡ → bắt buộc xác nhận.

### C03 — Chọn cầu thủ cho vị trí (KAN-58)
- Nhận `slotId` từ C04. Ứng viên = thẻ sở hữu của UID (bảng `owned_players`, mảng E ghi).
- Tìm theo tên (không dấu); công tắc "Chỉ hiện cầu thủ đúng vị trí" (mặc định bật).
- Sắp xếp: đúng vị trí trước → điểm vị trí (`positionRatings`, lấy cao nhất trong các vị trí slot chấp nhận) giảm dần → tên.
- Mỗi slot chấp nhận vị trí chính và vị trí gần giống, vd. LB nhận LWB; LW nhận LM/LF; CM nhận CDM/CAM.
- **Một cầu thủ không ở hai slot**: chọn người đang ở slot khác → hỏi "Chuyển sang?" → slot cũ bỏ trống. SQLite cũng có `UNIQUE(lineup_id, player_id)`.
- **Lệch vị trí**: cảnh báo, người dùng vẫn có thể xếp.
- Bộ sưu tập rỗng → hướng dẫn thêm thẻ ở E02 (bản debug có nút "Thêm thẻ mẫu" để thử khi E chưa xong).
- Slot không có trong sơ đồ hiện tại → báo lỗi + quay lại sân.

### C04 — Sân đội hình và lưu (KAN-53)
- Sân vẽ theo toạ độ % (0–100) của từng slot, tự co giãn theo màn hình, xoay ngang thì sân và thông tin nằm cạnh nhau.
- Slot trống: chạm → C03. Slot có người: chạm → Thay / Bỏ trống.
- Đổi tên (chạm tiêu đề), đổi sơ đồ (nút ▦ → C02), **Lưu**, **Hoàn tác** thay đổi chưa lưu.
- Thoát khi chưa lưu → hộp thoại **Lưu / Bỏ thay đổi / Ở lại**; lưu lỗi thì ở lại.
- Cảnh báo: slot **vàng** = lệch vị trí; slot **đỏ** = thẻ không còn trong bộ sưu tập (có nút "Gỡ").

## 3. Thiết kế (SDS)

```text
C0x Screen ──watch──▶ ViewModel (ui/lineups/view_models)
                         │
                         ▼
          LineupRepository / OwnedPlayerRepository / PlayerRepository   (data/repositories)
                         │
     LineupLocalService (SQLite) · LineupFirestoreService · OwnedPlayerService · PlayerApi/Cache/Sample   (data/services)
```

### Dữ liệu
- `domain/models/formation.dart`: `FormationSlot(id, role, x, y, alsoFits)`, `Formations.f433/f442`, `planFormationChange`, `assignPlayer` — logic thuần Dart.
- `domain/models/lineup.dart`: `Lineup(id, uid, name, formationId, slots{slotId→playerId}, createdAt, updatedAt)`.
- SQLite (`data/services/local_database_service.dart`, **file chung — đổi bảng cần C và E review**):
  - `lineups(id PK, uid, name, formation_id, created_at, updated_at, synced_at)`
  - `lineup_slots(lineup_id FK cascade, slot_id, player_id, PK(lineup_id, slot_id), UNIQUE(lineup_id, player_id))`
  - `lineup_deletions(id PK, uid, deleted_at)` — xoá khi offline, chờ xoá trên Firestore
  - `owned_players(uid, player_id, …)` — E ghi, C đọc; `player_cache` — B ghi, C đọc
- Firestore: `users/{uid}/lineups/{lineupId}` = `Lineup.toMap()`. Rules: `firestore.rules`.

### Đồng bộ (offline-first)
1. `save`: ghi SQLite (transaction) → thử đẩy Firestore (timeout 5 giây) → thành công thì đặt `synced_at`.
2. `delete`: xoá SQLite + ghi `lineup_deletions` → thử xoá Firestore.
3. `sync` (mở C01 / kéo làm mới): xoá các bản chờ → đẩy bản chưa đồng bộ → kéo bản Firestore có `updatedAt` mới hơn.
4. Không có Firebase (chưa `flutterfire configure`) → chỉ lưu SQLite, `SyncResult.enabled = false`.

### Phụ thuộc vào mảng khác (hợp đồng cần chốt khi merge)
| Cần | File trong PR này | Chủ sở hữu |
|---|---|---|
| UID phiên đăng nhập | `data/providers/current_user_provider.dart` (`currentUidProvider`) | D |
| Danh sách thẻ sở hữu | `data/repositories/owned_player_repository.dart` (`ownedPlayerIds(uid)`) | E |
| Thông tin cầu thủ theo ID | `data/repositories/player_repository.dart` (`getPlayersByIds`) | B |
| Model cầu thủ | `domain/models/player.dart` | B (A, C, E dùng) |

Khi chưa có Firebase/màn đăng nhập, `DemoAuthSessionService` trả người dùng `demo-user` để C chạy độc lập. `PlayerRepository` đọc cache → API → `assets/data/players_sample.json` (30 thẻ, 2 thẻ thật + 28 thẻ mẫu).

## 4. Kiểm thử

Tự động (`flutter test test/lineups`):

| File | Nội dung |
|---|---|
| `formation_test.dart` | 2 sơ đồ hợp lệ; đổi 4-3-3 → 4-4-2; gán/chuyển cầu thủ; `Lineup.toMap/fromMap` |
| `c03_c04_logic_test.dart` | Lọc/sắp ứng viên, điểm vị trí, tìm không dấu; cảnh báo lệch vị trí / không còn sở hữu |
| `lineup_view_models_test.dart` | Tạo/tên/UID/xoá-hoàn tác (C01); chưa lưu/lưu/hoàn tác; C02 huỷ và áp dụng; C03 hỏi chuyển + lệch vị trí |
| `c01_screen_test.dart` | Màn rỗng, danh sách theo UID, tạo qua hộp thoại, chưa đăng nhập |

Thủ công trên Android (subtask 4 của mỗi task):

| Task | Kịch bản |
|---|---|
| KAN-47 (C01) | Tạo → tắt app → mở lại vẫn còn; xoá → Hoàn tác; tắt mạng (khi có Firebase) → dải "chưa đồng bộ", vẫn tạo/sửa được |
| KAN-52 (C02) | Đổi rồi Back → không đổi; xếp đủ 11 người ở 4-3-3 → chọn 4-4-2 → cảnh báo gỡ CM, LW, ST, RW → xác nhận |
| KAN-57 (C04) | Xoay ngang; sửa rồi Back → hộp Lưu/Bỏ/Ở lại; Lưu → mở lại từ C01 đúng dữ liệu |
| KAN-62 (C03) | Chọn người đang ở ST cho RW → hỏi chuyển; bộ sưu tập rỗng → thông báo; thẻ bị xoá khỏi bộ sưu tập → slot đỏ ở C04 |
