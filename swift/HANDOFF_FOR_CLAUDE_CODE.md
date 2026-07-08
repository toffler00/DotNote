# Dot Note — SwiftUI UI 리디자인 핸드오프 (Claude Code 지시서)

> 이 문서는 Claude Code가 **그대로 실행**할 수 있는 UI 작업 지시서다.
> 확정 방향: **1c 베이스 · Barunpen 워드마크 · 밝은 아이보리 + 컬러 칩 · 웜 다크모드**.
> 디자인 근거는 이 프로젝트의 목업(`Dot Note 전체 화면`, `프로토타입`, `다크모드 & 정교화`)과
> 확정 토큰(`DotNoteTheme 토큰`)이다.

---

## 0. 가드레일 (반드시 지킬 것)

- **View 파일만 수정한다.** 저장·마이그레이션·필터·네트워킹 로직을 View에 넣지 않는다.
- 수정 금지(불가침): `Domain/DotNoteModels.swift`, `Store/*`(`DotNoteStore`, `SwiftDataDotNoteStore`,
  `InMemoryDotNoteStore`, 매퍼), `Migration/*`, `DotNoteAppModel`의 로드·저장 로직.
- 색·폰트명·픽셀 등 디자인 값은 **`DotNoteTheme.swift` 한 곳에만** 둔다. 데이터 레이어에 하드코딩 금지.
- 폰트명 raw String은 `DotNoteFontTheme` enum 뒤로 래핑한다 → 저장값은 case 이름, 브랜드 변경 시 데이터 마이그레이션 불필요.
- 큰 방향 전환(플로우 재설계·브랜드 재정의)은 착수 전 사람 확인.

## 0.1 보존할 브랜드 DNA

- 웜 아이보리 배경 + 웜 니어블랙 잉크 (라이트: `#FFFEF6` / `#3A302B`).
- **Barunpen(NanumBarunpenR) 워드마크** — "Dot Note" 및 화면 타이틀. (레거시 점선 아웃라인은 이 손글씨로 진화 확정.)
- 캘린더-우선 홈. 리스트는 캘린더 아래.
- **확장형 "＋ 새 기록" 행**(FAB 아님) → 탭 시 메모/그림/일기 타입 칩 인라인 확장.
- 엔트리 타입별 구분 surface (일기 연녹 · 그림 흰 캔버스 · 메모 아이보리).

---

## 1. 파일 배치

```
Rebuild/App/Design/
  DotNoteTheme.swift          ← 이미 작성됨 (이 프로젝트 swift/DotNoteTheme.swift 참고/복사)
  Components/
    MonthCalendar.swift
    CalendarDayCell.swift
    EntryRow.swift
    CreateActionRow.swift
    WeatherPicker.swift
    EmptyStateView.swift
Rebuild/App/Screens/
  CalendarHomeView.swift
  DiaryEditorView.swift        ← 기존 DotNoteEntryEditorView 리스타일/분리
  DrawingEditorView.swift
  MemoOverlayView.swift
  SettingsView.swift
  FontListView.swift
  CollectionView.swift
```
> `DotNoteRootView`는 `NavigationStack` + `.sheet(item:)` 구조를 유지하되, 내부 `DotNoteMigrationPreviewView`(List 프리뷰)를 `CalendarHomeView`로 교체한다.

---

## 2. 디자인 토큰 — DotNoteTheme.swift

**`swift/DotNoteTheme.swift`에 완성본이 있다. 그대로 프로젝트에 추가한다.** 요약:

### 색상 (스킴별 함수 — 순수 블랙 금지, 웜 다크 유지)

| token | light | dark |
|---|---|---|
| `paper` | `#FFFEF6` | `#1E1916` |
| `card` | `#FFFFFF` | `#2A231F` |
| `ink` | `#3A302B` | `#F2E9DE` |
| `inkSoft` | `#8A7F78` | `#9A8D84` |
| `faded` | `#CBC2B8` | `#6F645D` |
| `accent` | `#8A6D3B` | `#C9A56A` |
| `today` | `#E0A94F` | `#E0A94F` (동일) |
| `hairline` | black .08 | white .08 |
| `destructive` | `#D0453B` | 동일 |

사용: View에서 `@Environment(\.colorScheme) private var scheme` → `DotNoteTheme.Palette.paper(scheme)`.
(원하면 Asset Catalog Any/Dark 등록으로 대체 가능. 토큰 이름은 동일.)

### 엔트리 타입 (DotNoteEntryKind 확장, 데이터에서 파생)

| kind | surface(light) | surface(dark) | dot | dot(dark) | label |
|---|---|---|---|---|---|
| `.diary` | `#F6FCE2` | `#22301A` | `#7BA05B` | `#9DC578` | 일기 |
| `.drawing` | `#FFFFFF` | `#20262C` | `#5B8BB0` | `#7FB0D6` | 그림 |
| `.memo` | `#FFFDF4` | `#2C2519` | `#E0A94F` | `#E6B968` | 메모 |

- `chipBackground(scheme)` = dot.opacity(라이트 .16 / 다크 .22)
- `chipForeground(scheme)` = 라이트 dot / 다크 dotDark

### 간격 · 반경 · 그림자

- Spacing: 4 / 8 / 12 / 16 / 20 / 28 / 40 (xxs…xxl)
- Radius: 8 / 12 / 18 / 20 (sm/md/lg/xl)
- Card shadow: `black.opacity(0.14)`, radius 12, y 6

### 타이포 — DotNoteFontTheme

- case: `barunGothic, myeongjo, barunpen, brush, shinb7, flowerRoad, rock`
- `postScriptName`: `NanumBarunGothic / NanumMyeongjoEco / NanumBarunpenR / NanumBrush / SSShinb7 / SSFlowerRoad / SSRock`
- `font(size:)` = `.custom(postScriptName, size:)`
- **역할별**: `DotNoteType.wordmark = .barunpen` (워드마크·타이틀 고정), `DotNoteType.body(settings)` = `DotNoteSettings.bodyFontName` 매핑 (기본 `.barunGothic`).
- **Info.plist `UIAppFonts`에 7종 등록 필수.** (기존 앱 폰트 등록 확인 — 이미 있으면 재사용.)

### 날씨 — DotNoteWeather

- 저장값은 기존 `weather` String("맑음" 등) 그대로. 표시만 SF Symbol 매핑.
- `presets = ["맑음","구름조금","흐림","비","눈","바람"]`
- `symbolName(for:)`: 맑음→`sun.max`, 구름조금→`cloud.sun`, 흐림→`cloud`, 비→`cloud.rain`, 눈→`cloud.snow`, 바람→`wind`.

---

## 3. 공용 컴포넌트 사양

### CalendarDayCell
- 세로 스택: 날짜 숫자(원형 25–28pt) + 하단 dot 행(최대 3개, 타입 색).
- 상태: 기본(ink) / **오늘**(흰 텍스트 + `today` 앰버 채움 원) / 다른 달(faded) / **선택**(accent 1.5pt 링).
- dot: 그날 존재하는 타입의 `dot`(라이트) / `dotDark`(다크) 색, 중복 타입은 1개로.

### MonthCalendar
- 흰(`card`) 라운드 카드(radius xl) + card shadow. 다크는 `card` + hairline 보더.
- 헤더: "10월 2021"(sectionTitle, Nanum Bold 15) + `‹ ›` 월 이동(inkSoft).
- 요일 행(일~토, inkSoft 10.5) + 6주 그리드.
- 입력: `entries: [Date: [DotNoteEntry]]`(표시용 그룹, 저장 아님) + `@Binding selection`.

### CreateActionRow
- 접힘: `ink` pill "＋ 새 기록"(paper 텍스트). 탭 → `expanded` 토글, ＋ 45° 회전.
- 확장: 오른쪽으로 memo/drawing/diary 칩(`chipBackground`/`chipForeground`) pop 애니메이션.
- 칩 탭 → `onPick(kind)` → 에디터 진입(memo는 오버레이).

### EntryRow
- 타입 `chipBackground` 배경 라운드(radius md) + 좌측 dot + 제목(ink 13 semibold) + 메타(kind label + 날씨).
- 그림은 좌측에 imageData 썸네일(38pt 라운드).
- 우측 chevron(faded).

### WeatherPicker
- presets 6개를 SF Symbol 타일(44pt 라운드)로. 선택 시 `today` 앰버 강조.
- 선택 결과를 `weather` String에 저장.

### EmptyStateView
- 중앙 정렬: 문서+플러스 심볼(faded) + "아직 기록이 없어요" + "＋ 새 기록으로 오늘을 남겨보세요." 홈·모아보기 공용.

---

## 4. 화면별 지시

### 4.1 CalendarHomeView (DotNoteRootView 내부 교체)
- 배경 `paper`. 상단: 워드마크 "Dot Note"(`DotNoteType.wordmarkFont(size:34)`, ink) + 우측 ⋯(설정 진입).
- `CreateActionRow` → 타입별 에디터 present.
- `MonthCalendar`.
- 선택일 헤더("10월 N일 · 요일", inkSoft 11) + 해당일 `EntryRow` 리스트. 없으면 `EmptyStateView`.
- 데이터: `appModel.entries`를 `createdAt` 기준 `Dictionary(grouping:)`로 일별 그룹(표시용, 저장 아님).
- 엔트리 탭 → `editorMode = .edit(entry)`(기존 로직 유지).

### 4.2 DiaryEditorView (기존 Form 리스타일)
- 배경 `paper`. 헤더: 뒤로(‹, ink 2pt) + "일기"(워드마크 28) + 저장 원형 버튼(`.diary.dot`, 흰 체크).
- 본문 카드: `.diary.surface(scheme)` 라운드(xl) 안에 흰(다크는 어두운) 필드 카드들:
  - 요일 타이틀(body 폰트 Bold 20) / 날짜 행(chevron) / **WeatherPicker 행** / 제목 TextField / 본문 TextEditor(min 160) / 정렬 툴바(좌·중·우, 활성 = diary 틴트).
- 저장: `onCreate`/`onSave`(기존 async 클로저) 그대로. 정렬은 `textAlignment`, 그림 없음.

### 4.3 DrawingEditorView
- 헤더 저장 버튼 = `.drawing.dot`.
- 상단 날짜·날씨 인라인 + 제목 TextField.
- **흰 캔버스**(radius md, hairline 보더) — PencilKit/`Canvas` 드로잉. 결과 → `imageData`(기존 필드).
- 툴바: 색 6종(`ink,#D0453B,today,#5B8BB0,#7BA05B,흰색`) + 굵기 슬라이더 + 펜/지우개 토글 + 실행취소.
- 하단 본문 TextEditor(`.diary.surface` 톤).

### 4.4 MemoOverlayView
- 딤 배경(black .4) 위 중앙 카드(`.memo.surface`, radius xl, 큰 그림자).
- 날짜(body Bold 16) + 닫기(×). 본문 TextEditor만. 탭/닫기 시 `appModel.addMemo`(기존) 저장, 빈 내용이면 저장 스킵.

### 4.5 SettingsView
- 배경 `paper`. 뒤로 + "설정"(워드마크 36).
- 카드 그룹(`card`, radius lg): **테마**(폰트 → FontListView, 현재값 표시) / **모아보기**(일기보기, 메모보기) / **지원**(의견보내기, 사용법, Open-source License) / **데이터삭제**(모든데이터 삭제 = `destructive`).
- 삭제는 **확인 다이얼로그 필수**("모든 데이터를 삭제할까요? / 되돌릴 수 없어요" · 취소/삭제).

### 4.6 FontListView
- `DotNoteFontTheme.allCases` 리스트. 각 행은 해당 폰트로 "displayName · 오늘의 기록" 렌더 + 선택 시 체크(diary dot).
- 선택 → `DotNoteSettings.bodyFontName = case.rawValue` 갱신(AppModel 통해). 저장 로직은 기존 경로.

### 4.7 CollectionView
- `settings.collectionFilter`로 일기/메모 분기(기존 필드). "일기보기": 2열 그리드 카드(imageData/그라디언트 썸네일 + 제목 + dot·날짜). 비어있으면 `EmptyStateView`.

---

## 5. 다크모드 규칙

- 순수 블랙 금지 — 위 표의 웜 다크 값 사용.
- `today` 앰버·타입 dot은 채도 유지(라이트와 동일)하되, 다크 surface 위 텍스트/칩엔 `dotDark` 사용.
- 모든 색 접근은 `DotNoteTheme.Palette.*(scheme)` / `kind.surface(scheme)` 경유. 하드코딩 색 리터럴 금지(토큰 파일 밖에서).
- 프리뷰에 `.preferredColorScheme(.dark)` 케이스 추가.

## 6. 작업 순서 (권장)

1. `DotNoteTheme.swift` 추가 + Info.plist 폰트 등록 확인.
2. 공용 컴포넌트(§3) → SwiftUI Preview로 라이트/다크 각각 검증.
3. `CalendarHomeView`로 `DotNoteRootView` 내부 교체.
4. 에디터(일기/그림) → 메모 오버레이.
5. 설정 / 폰트 / 모아보기.
6. 각 화면 Preview는 `InMemoryDotNoteStore` 스냅샷 사용(기존 `DotNoteRootView_Previews` 패턴).

## 7. 검증 체크리스트

- [ ] 저장/로드/삭제 동작이 기존 `DotNoteAppModel` 경로로만 흐른다(View에 저장 로직 없음).
- [ ] 색·폰트·간격 리터럴이 `DotNoteTheme.swift` 밖에 없다.
- [ ] `bodyFontName`에 저장되는 값이 `DotNoteFontTheme` case 이름이다.
- [ ] 라이트/다크 각각 6화면 Preview가 브랜드 톤을 유지한다.
- [ ] "＋ 새 기록" 확장, 오늘 앰버 필, 타입 dot, WeatherPicker 동작.
