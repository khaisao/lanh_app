
# Nghiên cứu và chính sách mục tiêu cân nặng cho Lành

## Quyết định phạm vi

Lành hỗ trợ người dùng từ 13 tuổi. Tuy nhiên, cùng một màn nhập liệu không thể áp dụng cùng một công thức cho mọi độ tuổi:

- 13–19 tuổi: dùng BMI-for-age theo tuổi và giới; không đặt tốc độ kg/tuần tự động.
- Từ 20 tuổi: dùng BMI người lớn và các tốc độ lập kế hoạch bảo thủ.
- Thai kỳ, sụt cân không chủ ý, bệnh nền hoặc thuốc ảnh hưởng cân nặng: không tự tạo kế hoạch cân nặng.

CDC quy định trẻ em và thanh thiếu niên phải được đánh giá bằng BMI theo tuổi và giới; AAP và NICE nhấn mạnh cách tiếp cận gia đình, không kỳ thị, có thể ưu tiên giữ cân và tăng trưởng vào vùng khỏe mạnh thay vì giảm cân trực tiếp. [CDC BMI-for-age](https://www.cdc.gov/bmi/child-teen-calculator/), [AAP guideline](https://publications.aap.org/pediatrics/article/151/2/e2022060640/190396), [NICE](https://www.nice.org.uk/guidance/ng246/chapter/Discussing-results-and-referral).

## Dữ liệu vị thành niên

Mã nguồn chứa các hàng LMS CDC 2000 ở tuổi 13–19, lấy tại điểm giữa mỗi tuổi để phù hợp với việc onboarding chỉ hỏi số tuổi nguyên:

- BMI dưới bách phân vị 5: dưới vùng tham chiếu.
- BMI từ bách phân vị 5 đến dưới 85: trong vùng tham chiếu.
- BMI từ bách phân vị 85 đến dưới 95: cao hơn vùng tham chiếu.
- BMI từ bách phân vị 95 trở lên: cần được chuyên gia đánh giá.

Các ngưỡng này là BMI-for-age, khác nhau giữa nam và nữ, và không được thay bằng BMI người lớn cố định. Nguồn dữ liệu gốc: [CDC Growth Charts Data Files](https://www.cdc.gov/growthcharts/cdc-data-files.htm).

UX cho nhóm này:

- Không hiện ô cân nặng mục tiêu hoặc ngày đạt mục tiêu.
- Hiện card “Mục tiêu an toàn trong giai đoạn lớn”.
- Dùng copy không kỳ thị, ưu tiên thói quen và nhịp tăng trưởng.
- Vẫn lưu ý định gain/lose/maintain để Home và hồ sơ biết bối cảnh.
- Cho phép tiếp tục app; không chẩn đoán hoặc kê kế hoạch điều trị.

## Dữ liệu người trưởng thành

CDC và NHS đều dùng khoảng 0,5–1,0 kg/tuần cho giảm cân từ từ. NIDDK dùng mục tiêu ban đầu 5–10% cân nặng trong khoảng 6 tháng. NHS khuyến nghị tăng cân dần bằng khoảng 300–500 kcal/ngày. [CDC loss](https://www.cdc.gov/healthy-weight-growth/losing-weight/index.html), [NHS loss](https://www.nhs.uk/live-well/healthy-weight/managing-your-weight/tips-to-help-you-lose-weight/), [NIDDK](https://www.niddk.nih.gov/health-information/weight-management/choosing-a-safe-successful-weight-loss-program), [NHS gain](https://www.nhs.uk/live-well/healthy-weight/managing-your-weight/healthy-ways-to-gain-weight/).

Chính sách sản phẩm hiện tại:

- Giảm: mặc định 0,5 kg/tuần; ngày làm tốc độ vượt 1,0 kg/tuần bị chặn bằng ngày bắt đầu tối thiểu trong date picker.
- Tăng: tham chiếu 0,25% trọng lượng/tuần; cảnh báo trên 0,5%/tuần. Mốc 0,25–0,5% chủ yếu xuất hiện trong tổng quan dinh dưỡng thể hình, nên đây là guardrail bảo thủ chứ không phải chuẩn y khoa cho mọi người. [PubMed review](https://pubmed.ncbi.nlm.nih.gov/31247944/).
- Mục tiêu giảm làm BMI người lớn cuối thấp hơn 18,5 bị từ chối.
- Card mục tiêu hiển thị tốc độ, số tuần, ngày dự kiến và trạng thái recommended/slower/too-fast/caution.

BMI người lớn là công cụ sàng lọc: dưới 18,5 thiếu cân; 18,5–<25 vùng khỏe mạnh; 25–<30 thừa cân; từ 30 béo phì. [CDC adult BMI](https://www.cdc.gov/bmi/adult-calculator/bmi-categories.html).

## Các giới hạn an toàn

- Không coi BMI là chẩn đoán.
- Không dùng chính sách này cho thai kỳ hoặc cho con bú.
- Không tự tạo kế hoạch khi người dùng báo sụt cân không chủ ý, bệnh nền hoặc thuốc ảnh hưởng cân nặng.
- Không dùng ngôn ngữ “thất bại”, “xấu” hoặc quy kết ý chí.

