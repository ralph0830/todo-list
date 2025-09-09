# Todo List 애플리케이션 PRD (Product Requirements Document)

## 프로젝트 개요
Rails 8.0 기반의 할 일 관리 웹 애플리케이션으로, 반복 할일 기능과 접기/펴기 UI를 포함합니다.

---

## 구현된 기능 목록

### 1. 기본 할일 관리
- ✅ 할일 추가/수정/삭제
- ✅ 할일 완료/미완료 토글
- ✅ 진행률 표시 (완료된 할일 비율)
- ✅ 진행중인 할일 / 완료된 할일 분리 표시

### 2. 반복 할일 기능
- ✅ 반복 주기 설정 (일일/주간/월간)
  - 일일: 월~금 08:30
  - 주간: 매주 월요일 08:30  
  - 월간: 매월 1일 08:30
- ✅ 반복 할일 자동 생성
- ✅ 반복 할일 관리 (활성화/비활성화)
- ✅ 반복 할일 삭제 기능

### 3. UI/UX 개선사항
- ✅ 완료된 할일 접기/펴기 기능
- ✅ 반복 할일 리스트 접기/펴기 기능
- ✅ 기본값: 모든 섹션 접힌 상태
- ✅ 반복 할일 삭제 확인 대화상자
- ✅ 모바일 반응형 디자인

---

## 기술적 구현 및 시행착오

### 접기/펴기 기능 구현 과정

#### 1차 시도: Stimulus Controller 사용
**목표**: Rails 표준 Stimulus 프레임워크로 접기/펴기 구현

**구현 코드**:
```javascript
// app/javascript/controllers/collapse_controller.js
export default class extends Controller {
  static targets = ["content", "icon", "text"]
  static values = { collapsed: Boolean }

  toggle() {
    this.collapsedValue = !this.collapsedValue
    // 복잡한 애니메이션 로직...
  }
}
```

**문제점**:
- Stimulus가 브라우저에서 로드되지 않음 (`window.Stimulus` undefined)
- `collapsedValue` 변경이 감지되지 않음
- 복잡한 애니메이션 로직으로 인한 버그

#### 2차 시도: Stimulus Controller 디버깅
**시도한 해결책**:
- 콘솔 로그 추가로 디버깅
- `collapsedValueChanged()` 콜백 추가
- 애니메이션 로직 단순화

**결과**: 여전히 Stimulus 로딩 문제로 해결되지 않음

#### 3차 시도: 순수 JavaScript 구현 (성공)
**최종 해결책**: Stimulus 완전 제거 후 순수 JavaScript 사용

**구현 코드**:
```javascript
function toggleSection(sectionId) {
  const content = document.getElementById(sectionId + '-content');
  const icon = document.getElementById(sectionId + '-icon');
  const text = document.getElementById(sectionId + '-text');
  
  if (content && icon && text) {
    if (content.style.display === 'none') {
      // 펴기
      content.style.display = 'block';
      icon.textContent = '▼';
      text.textContent = '접기';
    } else {
      // 접기
      content.style.display = 'none';
      icon.textContent = '▶️';
      text.textContent = '펴기';
    }
  }
}
```

**HTML 구조 변경**:
```erb
<button onclick="toggleSection('completed-tasks')">
  <span id="completed-tasks-icon">▶️</span>
  <span id="completed-tasks-text">펴기</span>
</button>

<div id="completed-tasks-content" style="display: none;">
  <!-- 내용 -->
</div>
```

### 반복 할일 삭제 기능

**구현 과정**:
1. 컨트롤러에 `@recurring_tasks` 데이터 추가
2. 뷰에 반복 할일 리스트 섹션 생성
3. X 버튼과 JavaScript 확인 대화상자 구현
4. Rails의 DELETE 메소드와 CSRF 토큰 처리

**핵심 JavaScript 코드**:
```javascript
function deleteRecurringTask(id, content) {
  if (confirm(`"${content}" 반복 할일을 삭제하시겠습니까?`)) {
    const form = document.createElement('form');
    form.method = 'POST';
    form.action = `/recurring_tasks/${id}`;
    
    // CSRF 토큰 추가
    const csrfInput = document.createElement('input');
    csrfInput.type = 'hidden';
    csrfInput.name = 'authenticity_token';
    csrfInput.value = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
    form.appendChild(csrfInput);
    
    // DELETE 메소드 오버라이드
    const methodInput = document.createElement('input');
    methodInput.type = 'hidden';
    methodInput.name = '_method';
    methodInput.value = 'DELETE';
    form.appendChild(methodInput);
    
    document.body.appendChild(form);
    form.submit();
  }
}
```

---

## 테스트 및 검증

### Playwright를 통한 자동화 테스트
**테스트 시나리오**:
1. 초기 상태 확인 (모든 섹션 접힘)
2. 완료된 할일 펴기 동작 확인
3. 반복 할일 펴기 동작 확인  
4. 다시 접기 동작 확인

**스크린샷 저장 위치**: `/home/ralph/docker/todo/screenshots/`

**테스트 결과**:
- ✅ 모든 접기/펴기 동작이 정상 작동
- ✅ 버튼 텍스트와 아이콘이 올바르게 변경됨
- ✅ 각 섹션이 독립적으로 동작함

---

## 교훈 및 개선사항

### 기술적 교훈
1. **Stimulus 의존성 문제**: Rails 환경에서도 JavaScript 프레임워크 로딩 이슈 발생 가능
2. **순수 JavaScript의 신뢰성**: 복잡한 프레임워크보다 단순한 해결책이 더 안정적일 수 있음
3. **테스트 우선 접근**: Playwright를 통한 실제 브라우저 테스트로 문제를 빠르게 발견

### 개발 프로세스 개선
1. **스크린샷 기반 검증**: 모든 UI 변경사항을 스크린샷으로 before/after 비교
2. **단계별 디버깅**: 콘솔 로그와 브라우저 개발자 도구 적극 활용
3. **대안 준비**: 주요 기능에 대한 대체 구현 방안 미리 준비

### 사용자 경험 개선
1. **직관적인 UI**: 펴기(▶️) / 접기(▼) 아이콘으로 명확한 상태 표시
2. **확인 대화상자**: 삭제와 같은 중요한 액션에 대한 사용자 확인
3. **기본 접힘 상태**: 초기 화면을 깔끔하게 유지하여 사용자 집중도 향상

---

## 향후 개발 방향

### 단기 계획
- [ ] 반복 할일 수정 기능 추가
- [ ] 할일 우선순위 기능
- [ ] 태그/카테고리 기능

### 장기 계획  
- [ ] 사용자 인증 시스템
- [ ] 팀 협업 기능
- [ ] 모바일 앱 개발
- [ ] API 제공

---

## 기술 스택

### Backend
- Ruby 3.3+
- Rails 8.0.2+
- SQLite3
- Puma 웹서버

### Frontend
- Tailwind CSS 4.x
- 순수 JavaScript (Stimulus 대신)
- 반응형 디자인

### 개발/배포
- Docker & Docker Compose
- Foreman (개발 환경)
- Playwright (자동화 테스트)

### 이메일 시스템
- Action Mailer
- Gmail SMTP
- Whenever (cron 스케줄링)

---

## 결론

이 프로젝트를 통해 **단순하고 확실한 해결책의 중요성**을 확인했습니다. 복잡한 프레임워크에 의존하기보다는, 문제의 본질을 파악하고 가장 직접적인 방법으로 해결하는 것이 때로는 더 효과적입니다. 

특히 **Playwright를 통한 실제 브라우저 테스트**는 개발 과정에서 매우 유용했으며, 스크린샷 기반의 before/after 비교는 UI 개발에서 필수적인 검증 방법임을 재확인했습니다.