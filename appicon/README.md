# Dot Note 앱 아이콘 — 적용 안내

확정 디자인: **솔리드 아이보리 `#FFFEF6` 배경 + Barunpen "D" (잉크 `#3A302B`) + 정중앙 위 accent 점 `#8A6D3B` + 하단 "Dot Note" 워드마크.**

## 파일
- `DotNote-icon-1024.png` — 1024px 마스터 (별도 편집용, `appicon/` 루트)
- `AppIcon.appiconset/` — Xcode 드롭인 세트 (iPhone + 마케팅), 기존 `Contents.json` 파일명과 동일

## 적용 (Claude Code / 수동)
1. 이 `AppIcon.appiconset/` 폴더 내용을 리포의
   `Orbit/Assets.xcassets/AppIcon.appiconset/` 로 덮어쓴다 (`Contents.json` 포함).
2. `AppIcon_dev.appiconset/` 도 개발 빌드에서 쓰면 동일 PNG를 복사해 넣는다.
3. Xcode에서 Assets 확인 → 클린 빌드.

## 참고
- 애플 가이드라인상 아이콘 자체엔 투명/둥근 모서리 불필요(시스템이 마스킹). 현재 정사각 풀블리드로 제작됨.
- 재생성이 필요하면 `appicon-master.html` 대신 `run_script` 캔버스 렌더(폰트 실측 중앙정렬)를 사용. 워드마크 없는 순수 Ḋ 버전이 필요하면 요청.
