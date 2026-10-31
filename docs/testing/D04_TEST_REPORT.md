# D04 – User Profile: Test Report

> Cập nhật sau khôi phục source ngày 2026-10-29: `flutter test --no-pub` đạt 83/83 test. `flutter analyze --no-pub` không có error/warning, còn 2 info `prefer_initializing_formals` trong auth_repository.dart và auth_service.dart. Integration emulator chưa chạy. Nội dung và evidence bên dưới là snapshot QA trước khôi phục (82 test), không phải log của lần chạy mới. Dependency hiện tại xem pubspec.lock.

Ngày kiểm thử: 2026-10-29 (Asia/Saigon). Project: PRM393 – TotalFootballVNG, package Dart `united2`.

**Kết quả: 82/82 unit/widget/regression tests PASS, trong đó 70 test mới cho D04. Integration emulator: NOT RUN. Chưa đủ bằng chứng để nghiệm thu toàn bộ D04 hoặc xác nhận tuân thủ SRS/SDS.**

## 1. Test Environment

| Thành phần | Phiên bản thực tế |
| --- | --- |
| OS / shell | Windows x64 / PowerShell |
| Flutter / Dart | 3.47.8 stable / 3.13.7 |
| SDK constraint | `^3.13.2` |
| flutter_riverpod / riverpod | 3.4.3 / 3.4.3 |
| riverpod_annotation / riverpod_generator | 4.0.7 / 4.0.9 |
| build_runner | 2.16.2 |
| firebase_core / firebase_auth | 4.15.2 / 6.7.1 |
| cloud_firestore | 6.10.2 |
| image_picker / http | 1.2.4 / 1.6.0 |
| mocktail / fake_cloud_firestore | 1.0.5 / 4.4.0 |
| mock_exceptions | 0.8.2 |
| flutter_test / integration_test | Flutter SDK |

Đã đọc `pubspec.yaml`, `pubspec.lock`, toàn bộ source D04, router, model/session/service Authentication, `app.dart`, `main.dart`, hai test hiện hữu và README. Tên thực tế là `UserProfileViewModel`, `UserProfileScreen`, `lib/data/services/cloudinary_service.dart`; không có class `D04ViewModel` hoặc `D04Screen` trong snapshot kiểm thử.

Kiến trúc hiện tại: Screen → Riverpod AsyncNotifier → ProfileRepository → Firestore/Cloudinary services. Model `UserProfile` chuyển đổi dữ liệu Firestore. Firebase Auth cung cấp UID cho ViewModel.

Repository đã có nhiều thay đổi chưa commit trước khi làm QA. Không reset/stash các thay đổi đó. Không thay routing, Firebase Rules, cấu hình Firebase production hoặc Cloudinary preset. Không đăng nhập tài khoản thật hay upload Cloudinary thật.

Dependency bổ sung có mục đích:

- `mocktail`: mock Firebase Auth/User và service boundary để kiểm tra lời gọi, tham số, lỗi.
- `fake_cloud_firestore`: kiểm thử service thật trên database trong bộ nhớ, gồm transaction tạo hồ sơ.
- `mock_exceptions`: API fault injection được fake_cloud_firestore hỗ trợ; package đã là dependency gián tiếp, nay khai báo trực tiếp vì test import nó. Tránh triển khai lớp Firestore `sealed`.
- `integration_test`: bài kiểm thử có Firebase plugin trên thiết bị/emulator.
- `http`: production service đã import trước đó nhưng chưa khai báo trực tiếp; giữ phiên bản 1.6.0 đã resolve. Dùng `MockClient` của chính package này.

## 2. Documentation References

Đã truy cập tài liệu chính thức trong phiên làm việc:

- [Flutter testing overview](https://docs.flutter.dev/testing/overview): phân lớp unit/widget/integration.
- [Flutter unit tests](https://docs.flutter.dev/cookbook/testing/unit/introduction): test độc lập, assertion và runner.
- [Flutter widget tests](https://docs.flutter.dev/cookbook/testing/widget/introduction): `WidgetTester`, pump, finder.
- [Flutter integration tests](https://docs.flutter.dev/testing/integration-tests): binding và chạy trên thiết bị.
- [Riverpod testing](https://riverpod.dev/docs/how_to/testing): container/scope riêng, overrides, giữ subscription cho auto-dispose.
- [Firestore](https://firebase.google.com/docs/firestore): nguồn chính thức cho lớp lưu trữ.
- [Firebase Rules unit tests](https://firebase.google.com/docs/rules/unit-tests): cần Rules tương ứng khi kiểm tra quyền trên emulator; fake lỗi không xác minh Rules.
- [Auth Emulator](https://firebase.google.com/docs/emulator-suite/connect_auth): dùng emulator và project demo.
- [Firestore Emulator](https://firebase.google.com/docs/emulator-suite/connect_firestore?hl=en): kết nối emulator và phân biệt kiểm tra dữ liệu server với cache.

URL gốc `https://firebase.google.com/docs/rules` và lần mở đầu `connect_firestore` bị timeout. Sau đó truy cập được hai trang chính thức thay thế nêu trên; không khẳng định đã đọc trang Rules overview bị lỗi. API test cũng được kiểm chứng bằng package thực tế, analyzer và execution. README/API trong cache của `fake_cloud_firestore 4.4.0` và `mock_exceptions 0.8.2` được đọc để chọn fault injection tương thích.

## 3. Requirements Traceability

**Không tìm thấy SRS/SDS** trong file tracked/untracked của repository, tìm kiếm tên SRS/SDS/PDF/DOCX ngoài thư mục build/cache, hoặc workspace agents được cung cấp. README không định nghĩa yêu cầu D04 chi tiết. Vì vậy không tự tạo mã FR/SRS/SDS và không kết luận feature mở rộng là yêu cầu bắt buộc từ SRS.

Các ID bên dưới là ID test nội bộ, không phải ID tài liệu nghiệp vụ.

| Nguồn yêu cầu có thể kiểm chứng | Hành vi hiện tại / phạm vi | Test liên kết |
| --- | --- | --- |
| SRS/SDS | Chưa có tài liệu để đối chiếu | BLOCKED: traceability tài liệu |
| Đề bài QA + `UserProfile.fromJson/toJson` | UID lấy từ document; email/name/default avatar; nullable; legacy `name`; timestamp | M01–M04 |
| Đề bài QA + Firestore service | `users/{uid}`, get/create, transaction ngăn trùng | F01–F03; V03–V05; I01 |
| Đề bài QA + validation service/screen | Trim tên; chiều dài Dart String 2–40; không ghi tên sai | F04–F05; W03–W05 |
| Source ViewModel | Chưa đăng nhập báo lỗi; dùng hồ sơ hiện có; fallback tên Auth/email/Player | V01–V06, V12 |
| Source ViewModel | Loading/Data/Error; chống thao tác chồng nhau; reload sau ghi | V07–V13; W01, W06–W08 |
| Mở rộng Cloudinary đã triển khai | Multipart upload, parse URL/public ID, rồi lưu Firestore | C01–C04; R02–R04; F06; I01 |
| Source screen | Icon mặc định, NetworkImage khi có URL, dialog, cancel/save/retry/reset | W01–W08 |
| Source router | Signed-out → Login; unverified → VerifyEmail; verified → Profile | G01 (3 biến thể) |
| Đề bài integration | Persist qua lần mở lại ứng dụng; permission-denied thực tế | I01, I02 – NOT RUN |

Avatar asset theo `avatarId` chưa được render: screen hiện chỉ dùng `Icons.person` khi không có URL, và pubspec chưa khai báo assets. Test xác minh hành vi hiện hữu, không tuyên bố đã có chọn avatar asset. Service upload chưa có timeout riêng; không viết test giả cho timeout chưa được triển khai.

## 4. Test Cases và mức độ ưu tiên

P0: dữ liệu/quyền truy cập/lỗi có thể làm gián đoạn thao tác. P1: chức năng chính. P2: tương thích và hiển thị phụ trợ. Các biến thể parameterized đều chạy như test độc lập.

| ID | Test cases / assertion chính | Ưu tiên | Số test |
| --- | --- | --- | ---: |
| M01 | Deserialize đầy đủ, UID từ document, timestamp cùng thời điểm | P1 | 1 |
| M02 | Serialize đúng map, không ghi timestamp server, round-trip | P1 | 1 |
| M03 | Map rỗng và trường null/invalid date có default đúng | P1 | 2 |
| M04 | Legacy name, ưu tiên displayName | P2 | 1 |
| F01–F03 | Missing → null; create/read/timestamps; duplicate không ghi đè | P0 | 3 |
| F04 | Tên sau trim dài 0/1/41 bị từ chối và dữ liệu cũ giữ nguyên | P0 | 3 |
| F05 | Tên dài 2/40 hợp lệ, trim, giữ email | P1 | 2 |
| F06 | Ghi URL/publicId; reset xóa cả hai, avatarId tùy chọn/default | P1 | 1 |
| F07–F09 | not-found; lỗi boundary; lỗi async get/update giữ nguyên FirebaseException | P0 | 3 |
| C01 | POST multipart có preset/file; parse secure_url/public_id | P1 | 1 |
| C02 | HTTP 400/401/500 báo upload thất bại | P0 | 3 |
| C03 | 9 response thiếu/sai/rỗng/non-object/malformed bị từ chối | P0 | 9 |
| C04 | Network ClientException được truyền nguyên vẹn | P0 | 1 |
| R01 | Delegate get/create/name/reset đúng tham số; không gọi upload | P1 | 1 |
| R02–R04 | Upload trước write; upload fail không write; write fail giữ lỗi | P0 | 3 |
| V01–V02 | Signed-out không đọc repo; existing profile Loading → Data, không create | P0 | 2 |
| V03 | Tạo profile với 3 nhánh tên Auth/email/Player | P1 | 3 |
| V04–V06 | Race create, StateError không có profile, read failure | P0 | 3 |
| V07 | Name/avatar/reset thành công; đang loading không nhận 3 loại lệnh trùng | P0 | 3 |
| V08 | Name/avatar/reset thất bại → AsyncError đúng lỗi | P0 | 3 |
| V09 | Cả 3 lệnh hoàn tất sau dispose không ném lỗi lifecycle | P0 | 3 |
| V10 | Cả 3 lệnh gặp profile bị xóa sau ghi → StateError rõ ràng | P0 | 3 |
| V11–V13 | Chặn lúc initial loading; create exception; refresh fail sau write | P0 | 3 |
| W01–W02 | Loading/thông tin/icon; ảnh URL dùng pixel cache, không gọi mạng | P1 | 2 |
| W03–W05 | Prefill/cancel; tên sai không lưu; save tên dài 2/40, trim và refresh | P1 | 4 |
| W06–W08 | Snackbar/error/retry; lỗi save; reset gọi ViewModel | P1 | 3 |
| G01 | Route profile với signed-out/unverified/verified | P0 | 3 |
| I01 | Auth emulator → profile/document → đổi tên → mock upload/write → reload → signed-out permission-denied | P0 | NOT RUN |
| I02 | Hai lần khởi chạy riêng: seed rồi verify dữ liệu server | P0 | NOT RUN |

Tổng D04 unit/widget/routing: **70**. Hồi quy hiện hữu: **9 Authentication + 3 Home = 12**. Tổng đã chạy cuối cùng: **82**.

## 5. Test Files Created

- `test/d04/user_profile_test.dart`
- `test/d04/profile_firestore_service_test.dart`
- `test/d04/cloudinary_service_test.dart`
- `test/d04/profile_repository_test.dart`
- `test/d04/user_profile_view_model_test.dart`
- `test/d04/user_profile_screen_test.dart`
- `test/d04/profile_routing_test.dart`
- `test/d04/support/profile_fakes.dart` – fake repository và mock Auth/User dùng chung.
- `integration_test/d04_profile_emulator_test.dart` – đã viết và static-analyze, chưa execute trên thiết bị.

`test/home_screen_test.dart` được cập nhật assertion theo UI hiện có 3 thẻ. Giữ nguyên các kiểm tra điều hướng và thêm assertion thẻ thứ ba xuống hàng; không xóa/skip test. `test/auth_flow_test.dart` không sửa.

## 6. Test Execution Results

| Lệnh / lần chạy | Kết quả thực tế |
| --- | --- |
| `flutter pub get` | PASS; resolve dependency test, không nâng chủ động package production |
| Unit D04 ban đầu | FAIL: 45 pass / 7 fail; 6 lỗi production lifecycle/null và 1 assertion timezone sai |
| D04 sau sửa + widget | PASS: 61/61 |
| Full suite lần đầu | FAIL: 75 pass / 1 fail; assertion Home cũ kỳ vọng 2 thay vì 3 thẻ |
| `dart run build_runner build --delete-conflicting-outputs --build-filter=...` | Exit 0 nhưng dọn generated output ngoài filter; flag delete-conflicting-outputs được phiên bản hiện tại thông báo đã bỏ và ignored |
| `dart run build_runner build` | PASS; sinh lại toàn bộ provider từ source, khắc phục output thiếu |
| `flutter test --coverage --reporter expanded` cuối cùng | **PASS: 82/82**, exit 0, runner khoảng 9 giây |
| `flutter analyze` strict | **FAIL gate (exit 1)** vì 2 info lint cũ ở auth_repository.dart và auth_service.dart; không còn error/warning |
| `flutter analyze --no-fatal-infos` | PASS gate; vẫn hiển thị 2 info lint, không che diagnostics |
| Integration I01 / I02 | **NOT RUN**; không tính vào 82 PASS |
| `git diff --check` | PASS, chỉ có thông báo quy đổi LF/CRLF của Git |

Evidence: [test output](evidence/flutter_test.txt), [strict analysis](evidence/flutter_analyze_strict.txt), [analysis without fatal infos](evidence/flutter_analyze.txt), [D04 LCOV](evidence/d04_lcov.info). Log đầy đủ cục bộ cũng nằm ở `.dart_tool/d04_test_run.log`; LCOV toàn suite ở `coverage/lcov.info`.

### Integration prerequisites và cách chạy lại

`firebase.json` hiện chỉ có cấu hình FlutterFire production, không có emulator config hoặc đường dẫn Rules. Không tìm thấy file Rules trong repository, và không có listener tại 8080/9099 khi kiểm tra. Việc liệt kê thiết bị bằng `flutter devices` không hoàn tất nên chưa xác nhận target phù hợp. Không chạy emulator với open rules để tuyên bố permission test PASS.

Cần một cấu hình emulator **riêng**, trỏ tới bản Rules đã được chủ dự án chấp thuận cho việc test; không sửa/deploy Rules production. Test hiện kiểm tra hợp đồng owner đọc/ghi `users/{uid}`, unauthenticated bị từ chối. Nếu Rules nghiệp vụ yêu cầu thêm email verification, cần đối chiếu tài liệu và chuẩn bị fixture Auth tương ứng trước khi chạy, không nới Rules để vượt test.

Ví dụ sau là hướng dẫn, **chưa thực thi**; `PATH_TO_APPROVED_EMULATOR_CONFIG` và `DEVICE_ID` phải được thay bằng giá trị thật:

```powershell
firebase emulators:start --project demo-totalfootball-d04 --only auth,firestore --config PATH_TO_APPROVED_EMULATOR_CONFIG
flutter test integration_test/d04_profile_emulator_test.dart -d DEVICE_ID --dart-define=D04_EMULATORS=true --dart-define=D04_EMULATOR_HOST=10.0.2.2
```

Host `10.0.2.2` dành cho Android emulator; desktop dùng `127.0.0.1`. Test từ chối host khác, yêu cầu flag opt-in, kiểm tra port với timeout ngắn, dùng named Firebase app thuộc project demo, không import FirebaseOptions production, và chỉ dùng HTTP MockClient cho Cloudinary. Chưa kiểm chứng native build/plugin runtime của file integration.

Để kiểm tra process restart, giữ emulator đang chạy, chọn RUN_ID mới, chạy lần lượt hai lệnh dưới cùng một cấu hình. Không thay bước verify bằng tạo lại profile:

```powershell
flutter test integration_test/d04_profile_emulator_test.dart -d DEVICE_ID --dart-define=D04_EMULATORS=true --dart-define=D04_EMULATOR_HOST=10.0.2.2 --dart-define=D04_RUN_ID=run001 --dart-define=D04_RESTART_PHASE=seed
flutter test integration_test/d04_profile_emulator_test.dart -d DEVICE_ID --dart-define=D04_EMULATORS=true --dart-define=D04_EMULATOR_HOST=10.0.2.2 --dart-define=D04_RUN_ID=run001 --dart-define=D04_RESTART_PHASE=verify
```

I01 kiểm tra SDK Auth → ViewModel → repository/service, không tự động thao tác UI đăng nhập trên thiết bị. UI login/navigation được kiểm tra bằng widget regression và G01 với fake. I02 kiểm tra dữ liệu server qua hai lần chạy, không xác minh phục hồi auth token tự động hoặc offline cache. Tài khoản thử nghiệm chỉ được tạo trong emulator; test không xóa dữ liệu production hay tự dọn emulator dùng chung.

## 7. Bugs Found

| ID | Nguyên nhân / bằng chứng | Xử lý |
| --- | --- | --- |
| BUG-D04-01 | 3 mutation gán `state` sau await dù auto-dispose đã xảy ra. V09 tái hiện lỗi Cannot use Ref after disposed. | FIXED: chỉ gán khi `ref.mounted` |
| BUG-D04-02 | Reload profile dùng `!`; document bị xóa gây TypeError. V10 tái hiện ở name/avatar/reset. | FIXED: StateError `Không tìm thấy hồ sơ người dùng` qua AsyncError |
| BUG-D04-03 | Parse Cloudinary ép kiểu trực tiếp, không kiểm tra field rỗng hoặc JSON không phải object. | FIXED: FormatException rõ ràng cho cấu trúc/field không hợp lệ; C03 xác minh |
| TEST-01 | Timestamp.toDate trả local DateTime; test so sánh equality với UTC. | Sửa test dùng isAtSameMomentAs; không sửa model |
| TEST-02 | Home test giả định 2 cards trong khi source đã có thêm upload demo card trước phiên QA. | Sửa kỳ vọng 3, kiểm tra wrap và giữ route assertions |
| TEST-03 | Mock trực tiếp Query/DocumentReference tạo sealed-class analyzer warnings. | Dùng fake fault injection; không suppress warning |
| TOOL-01 | build-filter dọn output generated không nằm trong filter. | Chạy generation đầy đủ; regression/analyzer xác nhận phục hồi |

Các lỗi `valueOrNull` và viết hoa provider đã được sửa trong source trước phiên QA này; không nhận đó là thay đổi của bộ test hiện tại.

## 8. Production Code Changes

- `lib/ui/authentication/view_models/user_profile_view_model.dart`: thêm `profileAuthProvider` overridable, production vẫn dùng `FirebaseAuth.instance`; giữ luồng nghiệp vụ và tên provider hiện có. Ba mutation kiểm tra mounted sau await và thay null assertion bằng lỗi có ý nghĩa.
- `lib/data/services/cloudinary_service.dart`: thêm optional HTTP client do caller sở hữu; khi không inject vẫn dùng request.send như trước. Kiểm tra response JSON là object, secure_url/public_id là chuỗi không rỗng. Không thay endpoint, preset, kích thước ảnh hoặc cơ chế upload.
- `pubspec.yaml`/`pubspec.lock`: dependency như mục 1. Provider generated được chạy lại từ source; không chỉnh tay `.g.dart`.
- Không sửa screen, model, Firestore service, profile repository, auth business logic hoặc router trong phiên QA. Các diff có sẵn của người dùng ở những file đó vẫn được giữ.

## 9. Coverage

Line coverage đo thực tế từ lượt `flutter test --coverage` cuối; chỉ cộng 6 file D04 production chính, không cộng `.g.dart`, test hoặc màn demo upload.

| File | Covered / executable lines | Line coverage |
| --- | ---: | ---: |
| user_profile.dart | 22 / 22 | 100% |
| cloudinary_service.dart | 20 / 20 | 100% |
| profile_firestore_service.dart | 31 / 32 | 96.88% |
| profile_repository.dart | 14 / 18 | 77.78% |
| user_profile_view_model.dart | 44 / 45 | 97.78% |
| user_profile_screen.dart | 67 / 76 | 88.16% |
| **Tổng D04** | **198 / 213** | **92.96%** |

Đây không phải branch coverage, Rules coverage hoặc chứng cứ kết nối backend thật. Các constructor/provider mặc định dùng Firebase thật và nhánh image picker native chưa được exercise. 100% line coverage của Cloudinary vẫn không xác minh preset/server thực tế hoặc mọi nhánh giao thức.

## 10. Remaining Risks

- **P0 / NOT RUN:** emulator integration, native plugin runtime, permission-denied qua Rules thật và restart persistence. Cần cấu hình/Rules test đã được chấp thuận và thiết bị test.
- **Chưa thể trace SRS/SDS:** chưa xác nhận yêu cầu avatar asset, validation theo grapheme hay UTF-16 code units, và policy profile chính thức.
- Unit Firestore dùng fake: không chứng minh contention/retry transaction, index, Rules hay behavior server. F08/F09 chỉ chứng minh lỗi được truyền qua service.
- Image picker/gallery/cancel/permission và network image error ngoài cache chưa chạy trên thiết bị. W02 kiểm tra wiring ảnh bằng cache cục bộ, không tải ảnh thật.
- Upload thành công nhưng Firestore thất bại có thể để lại ảnh Cloudinary không được tham chiếu. R04 xác nhận báo đúng lỗi; cleanup server cần thiết kế riêng, không thêm API Secret vào app.
- Cloudinary chưa có timeout/cancellation policy riêng. Không thêm behavior mới khi chưa có yêu cầu.
- Avatar mặc định vẫn là icon, không ánh xạ avatarId sang asset. Tên sai hiện không lưu nhưng dialog chưa giải thích bằng thông báo validation. Đây là giới hạn UI hiện tại, chưa xác nhận là vi phạm SRS.
- Home hiện có thẻ upload demo và chưa thấy lối mở profile từ Home; G01 kiểm tra named route, không tuyên bố user journey Home → Profile đã hoàn chỉnh.
- Hai lint `prefer_initializing_formals` có sẵn trong Authentication khiến strict `flutter analyze` exit 1; giữ ngoài phạm vi sửa production D04.

## 11. Final Assessment

**Unit/widget/regression đã xác minh PASS: 82/82.** Các lỗi D04 đã sửa có test hồi quy tương ứng. Không còn error/warning từ analyzer; vẫn có 2 info ngoài D04 và strict analysis gate chưa sạch hoàn toàn.

**Chưa nghiệm thu D04 end-to-end.** Integration quan trọng và đối chiếu SRS/SDS còn thiếu; trạng thái này không được đổi thành PASS chỉ vì test cô lập có coverage cao. Bước tiếp theo là cung cấp SRS/SDS cùng cấu hình emulator/Rules test phù hợp, chạy I01 và hai phase I02, rồi cập nhật báo cáo bằng log thực tế.
