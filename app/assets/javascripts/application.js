// TodoList Enhanced JavaScript
document.addEventListener('DOMContentLoaded', function() {
  
  // 다크 테마 토글 기능
  const themeToggle = document.querySelector('.theme-toggle');
  const body = document.body;
  
  // 로컬 스토리지에서 테마 설정 불러오기
  const savedTheme = localStorage.getItem('theme') || 'light';
  if (savedTheme === 'dark') {
    body.classList.add('dark-theme');
  }
  
  // 테마 토글 이벤트
  if (themeToggle) {
    themeToggle.addEventListener('click', function() {
      body.classList.toggle('dark-theme');
      const isDark = body.classList.contains('dark-theme');
      localStorage.setItem('theme', isDark ? 'dark' : 'light');
      
      // 아이콘 변경 애니메이션
      this.style.transform = 'scale(0.8)';
      setTimeout(() => {
        this.style.transform = 'scale(1)';
      }, 150);
    });
  }
  
  // Task 추가 시 애니메이션
  const taskForm = document.querySelector('form[action="/tasks"]');
  const taskInput = document.querySelector('input[name="task[content]"]');
  
  if (taskForm && taskInput) {
    taskForm.addEventListener('submit', function(e) {
      if (taskInput.value.trim() === '') {
        e.preventDefault();
        taskInput.focus();
        taskInput.classList.add('shake');
        setTimeout(() => {
          taskInput.classList.remove('shake');
        }, 500);
        return;
      }
      
      // 제출 버튼 로딩 상태
      const submitBtn = this.querySelector('input[type="submit"]');
      if (submitBtn) {
        submitBtn.style.transform = 'scale(0.95)';
        submitBtn.style.opacity = '0.7';
      }
    });
    
    // 입력 시 실시간 글자 수 체크
    taskInput.addEventListener('input', function() {
      const maxLength = 200;
      const currentLength = this.value.length;
      
      // 글자 수 표시 (기존에 있다면)
      let charCounter = document.querySelector('.char-counter');
      if (!charCounter && currentLength > maxLength * 0.8) {
        charCounter = document.createElement('div');
        charCounter.className = 'char-counter text-xs text-gray-500 mt-1';
        this.parentNode.appendChild(charCounter);
      }
      
      if (charCounter) {
        charCounter.textContent = `${currentLength}/${maxLength}`;
        if (currentLength > maxLength * 0.9) {
          charCounter.classList.add('text-orange-500');
        } else {
          charCounter.classList.remove('text-orange-500');
        }
      }
    });
  }
  
  // 체크박스 클릭 시 애니메이션 효과
  const checkboxes = document.querySelectorAll('input[type="checkbox"]');
  checkboxes.forEach(checkbox => {
    checkbox.addEventListener('change', function() {
      const taskItem = this.closest('.group');
      if (taskItem) {
        if (this.checked) {
          // 완료 애니메이션
          taskItem.style.transform = 'scale(0.98)';
          taskItem.style.opacity = '0.7';
          setTimeout(() => {
            taskItem.style.transform = 'scale(1)';
            taskItem.style.opacity = '1';
          }, 200);
          
          // 축하 효과
          createCelebrationEffect(taskItem);
        } else {
          // 미완료로 되돌릴 때
          taskItem.style.transform = 'scale(1.02)';
          setTimeout(() => {
            taskItem.style.transform = 'scale(1)';
          }, 200);
        }
      }
    });
  });
  
  // 축하 효과 함수
  function createCelebrationEffect(element) {
    const rect = element.getBoundingClientRect();
    const colors = ['#10b981', '#3b82f6', '#8b5cf6', '#f59e0b'];
    
    for (let i = 0; i < 6; i++) {
      setTimeout(() => {
        const particle = document.createElement('div');
        particle.style.cssText = `
          position: fixed;
          width: 6px;
          height: 6px;
          background: ${colors[Math.floor(Math.random() * colors.length)]};
          border-radius: 50%;
          pointer-events: none;
          z-index: 1000;
          left: ${rect.left + Math.random() * rect.width}px;
          top: ${rect.top + Math.random() * rect.height}px;
          animation: particle-float 1s ease-out forwards;
        `;
        
        document.body.appendChild(particle);
        setTimeout(() => particle.remove(), 1000);
      }, i * 100);
    }
  }
  
  // 스크롤 시 헤더 스타일 변경
  const header = document.querySelector('header');
  if (header) {
    window.addEventListener('scroll', function() {
      if (window.scrollY > 50) {
        header.classList.add('scrolled');
      } else {
        header.classList.remove('scrolled');
      }
    });
  }
  
  // 통계 카드 애니메이션
  const statCards = document.querySelectorAll('.stats-card');
  if (statCards.length > 0) {
    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          entry.target.style.animationPlayState = 'running';
        }
      });
    }, { threshold: 0.1 });
    
    statCards.forEach(card => {
      observer.observe(card);
    });
  }
  
  // Task 자동 저장 기능 (Draft)
  if (taskInput) {
    let saveTimeout;
    taskInput.addEventListener('input', function() {
      clearTimeout(saveTimeout);
      saveTimeout = setTimeout(() => {
        localStorage.setItem('taskDraft', this.value);
      }, 500);
    });
    
    // 페이지 로드 시 드래프트 복원
    const savedDraft = localStorage.getItem('taskDraft');
    if (savedDraft && taskInput.value === '') {
      taskInput.value = savedDraft;
      taskInput.classList.add('has-draft');
    }
    
    // 폼 제출 시 드래프트 삭제
    if (taskForm) {
      taskForm.addEventListener('submit', function() {
        localStorage.removeItem('taskDraft');
      });
    }
  }
  
  // 키보드 단축키
  document.addEventListener('keydown', function(e) {
    // Ctrl/Cmd + Enter로 빠른 할 일 추가
    if ((e.ctrlKey || e.metaKey) && e.key === 'Enter') {
      e.preventDefault();
      if (taskInput) {
        taskInput.focus();
      }
    }
    
    // Escape으로 입력 취소
    if (e.key === 'Escape') {
      if (taskInput && document.activeElement === taskInput) {
        taskInput.blur();
        taskInput.value = '';
      }
    }
  });
  
  // 터치 디바이스 감지 및 최적화
  if ('ontouchstart' in window) {
    document.body.classList.add('touch-device');
    
    // 터치 친화적 호버 효과
    const touchElements = document.querySelectorAll('.hover-lift, .touch-friendly');
    touchElements.forEach(element => {
      element.addEventListener('touchstart', function() {
        this.style.transform = 'translateY(-2px) scale(1.02)';
      }, { passive: true });
      
      element.addEventListener('touchend', function() {
        setTimeout(() => {
          this.style.transform = '';
        }, 150);
      }, { passive: true });
    });
  }
  
  // 성능 최적화: 이미지 지연 로딩
  const images = document.querySelectorAll('img[data-src]');
  if (images.length > 0 && 'IntersectionObserver' in window) {
    const imageObserver = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          const img = entry.target;
          img.src = img.dataset.src;
          img.classList.remove('lazy');
          imageObserver.unobserve(img);
        }
      });
    });
    
    images.forEach(img => imageObserver.observe(img));
  }
  
});

// CSS 애니메이션 키프레임 추가
const style = document.createElement('style');
style.textContent = `
  .shake {
    animation: shake 0.5s ease-in-out;
  }
  
  @keyframes shake {
    0%, 100% { transform: translateX(0); }
    25% { transform: translateX(-5px); }
    75% { transform: translateX(5px); }
  }
  
  @keyframes particle-float {
    0% {
      opacity: 1;
      transform: translateY(0) scale(1);
    }
    100% {
      opacity: 0;
      transform: translateY(-50px) scale(0);
    }
  }
  
  .has-draft {
    border-color: #fbbf24 !important;
    box-shadow: 0 0 0 1px #fbbf24;
  }
  
  header.scrolled {
    background: rgba(255, 255, 255, 0.95) !important;
    backdrop-filter: blur(20px);
    box-shadow: 0 1px 20px rgba(0, 0, 0, 0.1);
  }
  
  .dark-theme {
    background: linear-gradient(135deg, #1f2937 0%, #111827 100%);
    color: #f9fafb;
  }
  
  .dark-theme header {
    background: rgba(17, 24, 39, 0.8);
    border-bottom-color: rgba(75, 85, 99, 0.3);
  }
  
  .dark-theme .glass {
    background: rgba(17, 24, 39, 0.8);
    border-color: rgba(75, 85, 99, 0.3);
  }
  
  .dark-theme .bg-white\\/90 {
    background: rgba(31, 41, 55, 0.9) !important;
  }
  
  .dark-theme .text-gray-800 {
    color: #f9fafb !important;
  }
  
  .dark-theme .text-gray-600 {
    color: #d1d5db !important;
  }
  
  .dark-theme .bg-gray-50 {
    background-color: #374151 !important;
  }
  
  .stats-card {
    animation: fadeInUp 0.6s ease-out;
    animation-play-state: paused;
  }
  
  @keyframes fadeInUp {
    from {
      opacity: 0;
      transform: translateY(20px);
    }
    to {
      opacity: 1;
      transform: translateY(0);
    }
  }
`;

document.head.appendChild(style);