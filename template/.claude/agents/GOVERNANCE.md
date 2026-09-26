# 에이전트 거버넌스

이 파일은 사람만 수정. 에이전트는 읽기만.

## 현재 등록 에이전트 (6/8)

| 이름 | 파일 | 역할 | 호출 빈도 |
|-----|------|-----|---------|
| mistake-logger | mistake-logger.md | 실수 → recent.md 기록 | 실수 발생 시 (자동) |
| rule-promoter | rule-promoter.md | 반복 패턴 → rules.md 승격 제안 | 주 1회 |
| rule-deprecator | rule-deprecator.md | 규칙 유효성 검토·삭제·승격 제안 | session-analyzer 트리거 또는 수동 |
| mistake-compressor | mistake-compressor.md | recent.md 200줄 초과 시 아카이브 | 월 1회 |
| session-analyzer | session-analyzer.md | questions.md 분석·규칙 효과성·INDEX 최적화 | 월 1회 |
| agent-synthesizer | agent-synthesizer.md | 반복 수동 패턴 → 신규 에이전트 초안 | session-analyzer 트리거 또는 수동 |

## 한도

**최대 8개**. 추가 전 반드시 기존 에이전트와 역할 중복 검토.
@agent-synthesizer가 새 에이전트 초안을 제안해도, GOVERNANCE.md 등록 + 사람 승인 없이는 유효하지 않음.

## 삭제 로그

| 날짜 | 이름 | 삭제 이유 |
|------|-----|---------|
| (없음) | | |

## 에이전트 추가 절차

1. @agent-synthesizer 또는 사람이 초안 제안
2. 역할·중복·한도(8개) 검토
3. 파일 생성 → 이 테이블에 등록
4. 2주 후 효과 검토 (questions.md ↩ 비율 개선 여부)
