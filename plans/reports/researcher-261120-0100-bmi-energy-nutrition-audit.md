# Kiểm tra quy tắc BMI, năng lượng và kế hoạch cân nặng (Profile Setup)

Ngày: 2026-11-20. Phạm vi: chỉ đọc code, không sửa. Số liệu ví dụ được tính lại bằng công thức copy từ code (script nằm ngoài repo).

## Kết luận chính

Phần lõi đúng hướng. Ngưỡng BMI châu Á 18,5/23/25, Mifflin‑St Jeor, PAL theo FAO/WHO/UNU, sàn 1.200/1.500 kcal, giới hạn tốc độ 0,5–1 kg/tuần và quy tắc không tính kcal cho tuổi 13–19 đều có cơ sở. Có năm điểm cần sửa, xếp theo mức độ:

1. **Đã xác nhận (20/11/2026):** chủ dự án xóa công tắc này có chủ đích; app mặc định người dùng không mang thai và tính như bình thường. Ghi chú gốc: bản làm việc hiện tại (chưa commit) đã **xóa công tắc "Đang mang thai hoặc cho con bú"**. Ở HEAD, `profile_body_step.dart`, `profile_setup_screen.dart` và `profile_plan_sheet.dart` lần lượt có 12, 16 và 8 tham chiếu `pregn`; bản làm việc không còn tham chiếu nào. `docs/goal-mvp.md:43` vẫn mô tả công tắc này. Hệ quả là một phụ nữ mang thai sẽ nhận được ngân sách kcal có thâm hụt.
2. **Sai (P0, copy):** `app_vi.arb:406` và `app_en.arb:290` ghi trần tăng cân là "BMI 24,9", trong khi code (`goal_policy.dart:242`) và các chuỗi khác (`app_vi.arb:451`) dùng 22,9.
3. **Thiếu (P1):** người cao tuổi (≥65–70) được xử lý như người 30 tuổi. Một phụ nữ 70 tuổi có BMI 21,3 vẫn được gợi ý giảm xuống 43 kg (BMI 19,1), trái với bằng chứng lão khoa.
4. **Lệch (P2):** tuổi 13–19 đang dùng CDC 2000, trong khi Việt Nam (Viện Dinh dưỡng) dùng WHO 2007 với ngưỡng z‑score.
5. **Thiếu (P2):** ngân sách kcal cố định theo cân nặng ban đầu, nên ngày dự kiến sẽ lạc quan hơn thực tế (giới hạn của quy tắc 7.700 kcal/kg).

## 1. Bằng chứng (đã xếp theo độ tin cậy)

| Chủ đề | Bằng chứng | Nguồn |
|---|---|---|
| BMI người lớn châu Á | WPRO/IASO/IOTF 2000: thiếu cân <18,5; bình thường 18,5–22,9; thừa cân 23–24,9; béo phì I 25–29,9; béo phì II ≥30. WHO Expert Consultation 2004 giữ ngưỡng quốc tế 25/30 và thêm các "điểm hành động" 23/27,5/32,5/37,5 cho từng quốc gia tự chọn. | WHO WPRO 2000 (https://iris.who.int/handle/10665/206936); Lancet 2004;363:157‑63 (https://pubmed.ncbi.nlm.nih.gov/14726171/) |
| Việt Nam dùng ngưỡng nào | QĐ 2892/QĐ‑BYT (22/10/2022) "Hướng dẫn chẩn đoán và điều trị bệnh béo phì" được nguồn thứ cấp trích theo bảng châu Á 18,5/23/25/30, với vòng bụng ≥90 cm ở nam và ≥80 cm ở nữ. Tôi chưa đọc được bản gốc. | hoatieu.vn 2022 (https://hoatieu.vn/phap-luat/quyet-dinh-2892-qd-byt-2022-tai-lieu-chuyen-mon-huong-dan-chan-doan-dieu-tri-benh-beo-phi-217088); Tâm Anh (https://tamanhhospital.vn/bao-nhieu-can-la-beo-phi/) |
| BMI theo tuổi cho tuổi teen | CDC dùng cho 2–19 tuổi: <P5 thiếu cân, P5–<P85 khỏe mạnh, P85–<P95 thừa cân, ≥P95 béo phì. WHO 2007 dùng cho 5–19 tuổi: >+1SD thừa cân, >+2SD béo phì, <−2SD gầy. Viện Dinh dưỡng Quốc gia (NIN) dùng WHO 2007. | CDC (https://www.cdc.gov/bmi/child-teen-calculator/bmi-categories.html); WHO (https://www.who.int/tools/growth-reference-data-for-5to19-years/indicators/bmi-for-age); NIN (https://viendinhduong.vn/en/professional-activities/proper-nutrition-for-school-age-children/67edfc033506f7c60f048922) |
| Teen và ăn kiêng | AAP khuyên không đặt chế độ hạn chế kcal hay nói về cân nặng với vị thành niên nếu không có chuyên gia theo dõi. | Golden et al., Pediatrics 2016;138:e20161649; Hampl et al., AAP CPG, Pediatrics 2023;151:e2022060640 |
| Công thức BMR | Mifflin‑St Jeor dự đoán trong khoảng ±10% ở khoảng 82% người không béo phì và 70% người béo phì, là công thức tin cậy nhất trong tổng quan hệ thống. Ở người châu Á, sai số lệch về hướng ước tính cao, nhưng chiều sai số không nhất quán giữa các nghiên cứu. | Frankenfield et al., J Am Diet Assoc 2005;105:775‑89 (https://pubmed.ncbi.nlm.nih.gov/15883556/); tổng hợp các nghiên cứu châu Á, độ tin cậy trung bình |
| PAL | FAO/WHO/UNU 2004 chia ba dải: ít vận động/nhẹ 1,40–1,69 (ví dụ 1,53); hoạt động vừa 1,70–1,99 (ví dụ 1,76); nặng 2,00–2,40 (ví dụ 2,25). PAL trên 2,40 khó duy trì lâu dài. | https://www.fao.org/4/y5686e/y5686e07.htm |
| Năng lượng tham chiếu VN | Bảng NIN/BYT, theo trích dẫn thứ cấp: nữ 30–49 tuổi lao động nhẹ/vừa/nặng 1.730/2.010/2.300 kcal; nữ ≥70 tuổi 1.550/1.820/2.090; nam 30–49 tuổi 2.010/2.350/2.680. Tỷ lệ vừa/nhẹ là 1,16 và nặng/nhẹ là 1,33. Mang thai cộng 50/250/450 kcal theo tam cá nguyệt; cho con bú cộng 500 kcal. | Tâm Anh trích NIN (https://tamanhhospital.vn/1-ngay-can-bao-nhieu-calo/); chưa có bản gốc 2016 |
| Tốc độ giảm cân | NHS: 0,5–1 kg/tuần. CDC: 1–2 lb/tuần. NHLBI: giảm 5–10% trong khoảng 6 tháng. | https://www.nhs.uk/live-well/healthy-weight/managing-your-weight/; https://www.cdc.gov/healthy-weight-growth/losing-weight/; https://www.nhlbi.nih.gov/health/educational/lose_wt/eat/calories.htm |
| Sàn kcal | AHA/ACC/TOS 2013: nữ 1.200–1.500, nam 1.500–1.800 kcal/ngày, hoặc thâm hụt 500–750 kcal. Dưới 800 kcal chỉ dùng khi có giám sát y tế. Trang NHLBI mà code đang trích **không** nêu các mức kcal này. | Jensen et al., Circulation 2014;129:S102‑38 |
| Quy tắc 7.700 kcal/kg | Chỉ đúng ở giai đoạn đầu. Tiêu hao năng lượng giảm dần khi cân giảm, và khoảng một nửa mức thay đổi cân nặng đạt được sau khoảng 1 năm. | Hall et al., Lancet 2011;378:826‑37 (https://pubmed.ncbi.nlm.nih.gov/21872751/) |
| Người cao tuổi | Ở người ≥65 tuổi, tử vong thấp nhất khi BMI khoảng 27–28 và tăng khi BMI <23. ESPEN: tránh chế độ giảm cân ở người cao tuổi thừa cân; ở người béo phì chỉ giảm khi có bệnh liên quan, với thâm hụt vừa phải kèm vận động. GLIM cho châu Á: BMI thấp nghĩa là <18,5 nếu <70 tuổi và <20 nếu ≥70 tuổi. | Winter et al., AJCN 2014;99:875‑90 (https://pubmed.ncbi.nlm.nih.gov/24452240/); Volkert et al., Clin Nutr 2019;38:10‑47; Cederholm et al., Clin Nutr 2019;38:1‑9 |
| Tăng cân | Không có guideline cộng đồng về tốc độ tăng cân. Thực hành phổ biến là thặng dư 300–500 kcal, tăng 0,25–0,5% cân nặng mỗi tuần (bằng chứng chủ yếu từ thể thao). | Iraki et al., Sports 2019;7:154 |
| Gầy | WHO phân loại BMI 17–18,49 là gầy nhẹ, 16–16,99 là gầy vừa và <16 là gầy nặng, cần chuyên gia đánh giá. | WHO BMI classification |

Đánh giá độ tin cậy: WHO, FAO, AHA và CDC là nguồn chính thức. Các trích dẫn về BYT/NIN đều là nguồn thứ cấp (bệnh viện, trang luật), nên ngưỡng Việt Nam khớp với bảng châu Á nhưng chưa được xác minh với bản gốc.

## 2. Đối chiếu từng quy tắc

| # | App đang làm (file:line) | Kết luận | Đề xuất |
|---|---|---|---|
| 1 | Ngưỡng 18,5 / 23 / 25 (`body_metrics.dart:26‑33,46‑52`) | **Đúng.** Khớp WPRO 2000 và BYT 2022. | Không cần sửa. |
| 2 | Nhãn BMI 18,5–22,9 là "Trong khoảng thường gặp" (`app_vi.arb:80`); ≥25 là "Cần được chuyên gia đánh giá" | **Lệch nhỏ.** "Thường gặp" không có nghĩa là bình thường (WHO gọi là normal). Nhãn cho ≥25 hợp lý vì BYT gọi mức này là béo phì độ I. | Đổi thành "Trong vùng bình thường". Có thể tách thêm nhóm ≥30 nếu muốn. |
| 3 | Người lớn tính từ 20 tuổi (`body_metrics.dart:18`) | **Đúng.** Cả CDC và WHO đều dùng BMI theo tuổi đến 19 tuổi. | Không cần sửa. |
| 4 | Teen dùng CDC 2000 P5/P85/P95, lấy hàng giữa năm tuổi (`teen_bmi.dart:27‑174,212‑215`); copy ghi "(CDC)" (`app_vi.arb:83`) | **Lệch.** NIN dùng WHO 2007. Hai chuẩn chênh nhau khoảng 0,5–0,7 BMI (xem ví dụ D). Số liệu CDC đúng với file gốc. | Thay bằng WHO 2007 LMS (5–19 tuổi), với ngưỡng <−2SD, >+1SD và >+2SD. Sửa copy thành "(WHO)". |
| 5 | Teen không có kcal và không có mục tiêu cân (`energy_estimate.dart:128`, `goal-mvp.md:35`) | **Đúng** theo AAP. | Không cần sửa. |
| 6 | Mifflin‑St Jeor (`energy_estimate.dart:52‑61`) | **Đúng.** Đây là lựa chọn tốt nhất trong các công thức đơn giản. | Không cần sửa. |
| 7 | PAL: ngồi 1,40, nhẹ 1,55, vừa 1,75, nặng 2,00, chưa rõ 1,40 với dải 1,40–1,75 (`energy_estimate.dart:38‑49`) | **Đúng.** Các giá trị nằm trong dải FAO. Tỷ lệ nặng/ngồi là 1,43, gần tỷ lệ NIN 1,33 sau khi chỉnh theo PAL. | Gợi ý "Xây dựng, làm nông, **tập luyện nặng**" (`app_vi.arb:448`) dễ khiến người làm văn phòng tập gym 1 giờ/ngày chọn PAL 2,0, trong khi PAL thật của họ khoảng 1,6–1,75. Nên bỏ "tập luyện nặng" khỏi gợi ý và thêm câu "tập 45–60 phút/ngày thì chọn mức trên một bậc". |
| 8 | Sàn kcal = max(BMR; 1.200 nữ / 1.500 nam) (`energy_estimate.dart:149‑154`) | **Đúng về số, sai nguồn trích.** Sàn bằng BMR là heuristic bảo thủ và chấp nhận được. | Sửa comment `energy_estimate.dart:20‑21` và `goal-mvp.md:31` để trích Jensen 2013 AHA/ACC/TOS thay cho trang NHLBI. |
| 9 | 7.700 kcal/kg, ngân sách không được tính lại (`energy_estimate.dart:17‑19,69‑70`; `goal-mvp.md:47` "not re-run automatically yet") | **Thiếu.** Comment ghi "re-estimated from the new weight" nhưng code chưa làm. Ví dụ A sẽ chậm khoảng 15–25% so với ngày dự kiến. | Tính lại ngân sách mỗi khi cân giảm hoặc tăng khoảng 2 kg, hoặc mỗi 4 tuần. Ghi rõ ngày dự kiến là ước tính. |
| 10 | Giảm cân nhẹ nhàng: 10%/26 tuần; mức phổ biến 0,5–1 kg; trần = min(1 kg; 1%; sàn kcal) (`goal_policy.dart:35‑43,117‑139`) | **Đúng.** Khớp NHS, CDC và NHLBI. | Không cần sửa. Riêng NHLBI ghi "5–10% trong khoảng 6 tháng", nên nên sửa câu chữ trong docs. |
| 11 | Mục tiêu giảm 5/7/10%, cho phép xuống đến BMI 18,5 (`goal_policy.dart:233‑239`) | **Lệch nhỏ** với người có BMI bình thường. Guideline chỉ khuyến nghị giảm cân khi BMI ≥23 (châu Á) hoặc có nguy cơ. | Khi BMI <23, nên chỉ gợi ý 5% hoặc giữ đáy BMI khoảng 20, và hiện ghi chú "BMI đã trong vùng bình thường". |
| 12 | Không có quy tắc riêng cho người cao tuổi | **Thiếu.** Xem ví dụ C. | Khi ≥65 tuổi và BMI <23: không gợi ý giảm cân, khuyên Giữ cân. Khi ≥70 tuổi: đáy giảm cân là BMI 22–23 thay vì 18,5, kèm câu nhắc giữ cơ và ăn đủ đạm. |
| 13 | Tăng cân: trần BMI 22,9, nhẹ nhàng 0,25%/tuần, tối đa 0,5%/tuần, thặng dư tối đa 500 kcal (`goal_policy.dart:40‑41`, `energy_estimate.dart:27,107`) | **Đúng** (heuristic hợp lý). | Copy trần sai thành 24,9 (P0). Khi BMI <17 (gầy vừa hoặc nặng), nên hiện câu khuyên gặp chuyên gia. |
| 14 | Mang thai hoặc cho con bú | **Sai (P0)** trong bản làm việc vì công tắc đã bị xóa (xem trên). | Khôi phục công tắc ở HEAD. Có thể bổ sung câu hỏi về rối loạn ăn uống và bệnh mạn tính (đái tháo đường dùng insulin, bệnh thận). |
| 15 | Không gợi ý giảm khi sàn kcal chỉ cho phép dưới 0,1 kg/tuần (`energy_estimate.dart:97‑98`) | **Đúng.** | Không cần sửa. |

## 3. Ví dụ tính tay (so công thức app với khuyến nghị)

Ký hiệu: TDEE là tổng năng lượng tiêu hao mỗi ngày (BMR × PAL). App hiển thị kcal làm tròn theo bước 50 kcal.

**A. Nữ 32 tuổi, 165 cm, 61,5 kg, chủ yếu ngồi, muốn giảm cân.**
- BMI 22,6 (bình thường). BMR 1.325 kcal; TDEE 1.855 kcal (hiển thị 1.850); sàn 1.325 kcal (bằng BMR).
- Nhịp nhẹ nhàng 0,237 kg/tuần cho ngân sách 1.595 kcal (hiển thị **1.600**). Gợi ý 58, 57 và 55 kg, tương ứng 15, 20 và 28 tuần. Tốc độ tối đa 0,48 kg/tuần, ứng với 1.325 kcal.
- So với bằng chứng: TDEE hợp lý (NIN cho nữ 30–49 tuổi lao động nhẹ là 1.730 kcal ở cân nặng tham chiếu thấp hơn). App vẫn cho giảm đến 50,4 kg (BMI 18,5) dù người này không có chỉ định giảm cân.
- **Nên hiển thị:** 1.600 kcal là hợp lý. Nên kèm ghi chú "BMI đã trong vùng bình thường" và đáy mục tiêu khoảng BMI 20 (54,5 kg).

**B. Nam 25 tuổi, 175 cm, 58 kg, vận động nhẹ, muốn tăng cân.**
- BMI 18,9. BMR 1.554 kcal; TDEE 2.408 kcal (hiển thị 2.400).
- Nhịp nhẹ nhàng 0,145 kg/tuần cho ngân sách 2.568 kcal (hiển thị **2.550**). Gợi ý 61, 62 và 64 kg, tương ứng 21, 28 và 42 tuần. Tốc độ tối đa 0,29 kg/tuần, ứng với 2.727 kcal. Trần BMI 22,9 là 70,1 kg.
- **Đánh giá:** đúng. Thặng dư khoảng 160–320 kcal nằm trong thực hành thông thường. Lỗi duy nhất là copy ghi trần BMI 24,9.

**C. Nữ 70 tuổi, 150 cm, 48 kg.**
- BMI 21,3. Theo Winter 2014 (người ≥65 tuổi), mức này đã dưới vùng tử vong thấp nhất. BMR 907 kcal.
- Nếu chọn "ngồi": TDEE 1.269 kcal (hiển thị 1.250), sàn 1.200 kcal, giảm tối đa 0,063 kg/tuần. App không gợi ý giảm cân, nhưng chỉ nhờ trùng hợp của sàn kcal.
- Nếu chọn "nhẹ": TDEE 1.405 kcal, giảm tối đa 0,186 kg/tuần. App **gợi ý giảm xuống 46, 45 hoặc 43 kg** (BMI 19,1) với 1.200 kcal/ngày trong 11–28 tuần.
- **Nên hiển thị:** không có mục tiêu giảm cân, chuyển sang Giữ cân với khoảng 1.400 kcal (NIN cho nữ ≥70 tuổi lao động nhẹ là 1.550 kcal) và nhắc về đạm và vận động. Kết luận: **Sai về chính sách**.

**D. Teen nữ 15 tuổi (không có kcal, chỉ có trạng thái BMI).**
- 158 cm, 60 kg, BMI 24,03: theo CDC (P85 = 24,36) là "Trong vùng tham chiếu", nhưng theo WHO 2007 (+1SD = 23,83 ở 15,5 tuổi) là **thừa cân**.
- 160 cm, 41,5 kg, BMI 16,21: theo CDC (P5 = 16,55) là "Dưới vùng tham chiếu", nhưng theo WHO (−2SD = 16,04) là **bình thường**.
- Với nam 15 tuổi: ngưỡng thừa cân của WHO (+1SD) là 23,12, còn CDC (P85) là 23,83.
- **Kết luận:** với người dùng Việt Nam, nên dùng WHO 2007 theo chuẩn của NIN. Giá trị WHO lấy từ file `bmi-girls/boys-z-who-2007-exp.xlsx` tại cdn.who.int, ở các mốc 15,5 tuổi.

**E. Nam 45 tuổi, 170 cm, 80 kg, lao động nặng, muốn giảm cân.**
- BMI 27,7, thuộc béo phì độ I theo ngưỡng châu Á. BMR 1.643 kcal; TDEE 3.285 kcal (hiển thị 3.300).
- Nhịp nhẹ nhàng 0,308 kg/tuần cho ngân sách 2.947 kcal (hiển thị **2.950**). Gợi ý 76, 74 và 72 kg, tương ứng 13, 20 và 26 tuần. Trần 0,8 kg/tuần (giới hạn 1% cân nặng), ứng với 2.405 kcal.
- **Đánh giá:** đúng nếu người này thực sự làm lao động chân tay. Nếu thực ra chỉ "tập gym nặng" (PAL ~1,55–1,75), TDEE thật khoảng 2.550–2.870 kcal, nên ngân sách 2.950 kcal sẽ gây **tăng cân**. Đây là rủi ro mapping ở quy tắc 7. Cùng người này nếu chọn "nhẹ" thì nhận 2.200 kcal.

## 4. Thứ tự sửa đề xuất

1. **P0:** khôi phục công tắc mang thai/cho con bú, hoặc xác nhận với session đang sửa rằng việc xóa không phải chủ ý. Thêm test để chặn lỗi này tái diễn.
2. **P0:** sửa `profileTargetPickerRangeGain` (vi/en) từ 24,9 thành 22,9, rồi generate lại l10n.
3. **P1:** thêm quy tắc cho người ≥65 tuổi (không gợi ý giảm khi BMI <23; đáy BMI 22–23 khi ≥70 tuổi), kèm test cho ví dụ C.
4. **P1:** với người BMI 18,5–22,9 chọn giảm cân, giới hạn gợi ý (đáy khoảng BMI 20 hoặc chỉ 5%) và hiện ghi chú. Đây cũng là biện pháp giảm rủi ro rối loạn ăn uống ở phụ nữ trẻ.
5. **P2:** chuyển BMI teen sang WHO 2007 (đồng bộ với NIN và BYT) và sửa copy "(CDC)".
6. **P2:** tính lại ngân sách theo cân mới (mỗi ±2 kg hoặc mỗi 4 tuần). Sửa comment "re-estimated" cho khớp với hành vi thực tế.
7. **P3:** sửa gợi ý PAL "tập luyện nặng"; đổi nhãn "Trong khoảng thường gặp" thành "Trong vùng bình thường"; thêm câu khuyên gặp chuyên gia khi BMI <17.
8. **P3:** sửa nguồn trích của sàn 1.200/1.500 thành AHA/ACC/TOS 2013, và câu NHLBI thành "5–10% trong khoảng 6 tháng" (comment trong code và `goal-mvp.md`).

## 5. Giới hạn của nghiên cứu

- Chưa đọc bản gốc của QĐ 2892/QĐ‑BYT và của bảng Nhu cầu dinh dưỡng khuyến nghị 2016. Các con số BYT/NIN đều lấy từ nguồn thứ cấp.
- Chưa có nghiên cứu kiểm định Mifflin‑St Jeor trên người Việt khỏe mạnh. Các nghiên cứu châu Á cho kết quả không thống nhất.
- Không kiểm tra UI widget, các bước chuyển màn hình hay integration test. Chỉ chạy công thức, không chạy `flutter test`.

## Câu hỏi chưa giải quyết

1. Việc xóa công tắc mang thai trong bản làm việc là chủ ý (ví dụ chuyển sang màn khác) hay là lỗi?
2. Sản phẩm có muốn cho phép người BMI bình thường đặt mục tiêu giảm cân không, và đáy là bao nhiêu (18,5 hay 20)?
3. Ngưỡng tuổi "cao tuổi" nên là 65 hay 70? (ESPEN dùng ≥65; GLIM châu Á đổi ngưỡng ở 70.)
4. Có cần đọc bản gốc QĐ 2892 để xác nhận BYT áp dụng BMI người lớn từ 18 hay 20 tuổi không?
5. Có cần thêm câu hỏi sàng lọc rối loạn ăn uống hoặc bệnh mạn tính trước khi đưa ra con số kcal không?
