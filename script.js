// Enhanced JavaScript with all functionality
document.addEventListener('DOMContentLoaded', function() {
    initSmoothScrolling();
    initMobileMenu();
    initTabSystem();
    initCopyButtons();
    initTimelineAnimation();
    initTypewriterEffect();
    initScrollAnimations();
    initCodeHighlighting();
});

// Smooth scrolling for navigation links
function initSmoothScrolling() {
    const links = document.querySelectorAll('a[href^="#"]');
    
    links.forEach(link => {
        link.addEventListener('click', function(e) {
            e.preventDefault();
            
            const targetId = this.getAttribute('href');
            if (targetId === '#') return;
            
            const targetElement = document.querySelector(targetId);
            if (targetElement) {
                const offsetTop = targetElement.offsetTop - 80;
                
                window.scrollTo({
                    top: offsetTop,
                    behavior: 'smooth'
                });
                
                // Close mobile menu if open
                const navMenu = document.querySelector('.nav-menu');
                if (navMenu) {
                    navMenu.classList.remove('active');
                    resetMobileMenu();
                }
            }
        });
    });
}

// Mobile menu functionality
function initMobileMenu() {
    const toggle = document.querySelector('.nav-toggle');
    const menu = document.querySelector('.nav-menu');
    
    if (toggle && menu) {
        toggle.addEventListener('click', function() {
            menu.classList.toggle('active');
            animateHamburger();
        });
    }
}

// Animate hamburger icon
function animateHamburger() {
    const bars = document.querySelectorAll('.bar');
    const menu = document.querySelector('.nav-menu');
    
    if (menu.classList.contains('active')) {
        bars[0].style.transform = 'rotate(-45deg) translate(-5px, 6px)';
        bars[1].style.opacity = '0';
        bars[2].style.transform = 'rotate(45deg) translate(-5px, -6px)';
    } else {
        resetMobileMenu();
    }
}

// Reset mobile menu animation
function resetMobileMenu() {
    const bars = document.querySelectorAll('.bar');
    bars[0].style.transform = 'none';
    bars[1].style.opacity = '1';
    bars[2].style.transform = 'none';
}

// Tab system for code examples
function initTabSystem() {
    const tabBtns = document.querySelectorAll('.tab-btn');
    const tabContents = document.querySelectorAll('.tab-content');
    
    tabBtns.forEach(btn => {
        btn.addEventListener('click', function() {
            const tabName = this.textContent.trim().toLowerCase();
            let tabId;
            
            if (tabName.includes('terraform')) {
                tabId = 'terraform-output';
            } else if (tabName.includes('ansible')) {
                tabId = 'ansible-inventory';
            } else {
                return;
            }
            
            // Remove active class from all buttons and contents
            tabBtns.forEach(b => b.classList.remove('active'));
            tabContents.forEach(c => c.classList.remove('active'));
            
            // Add active class to current button and content
            this.classList.add('active');
            const targetTab = document.getElementById(tabId);
            if (targetTab) {
                targetTab.classList.add('active');
            }
        });
    });
}

// Copy code functionality
function initCopyButtons() {
    const copyButtons = document.querySelectorAll('.copy-btn');
    
    copyButtons.forEach(btn => {
        btn.addEventListener('click', function() {
            let codeBlock;
            
            // Find the closest code block
            if (this.closest('.content-code')) {
                codeBlock = this.closest('.content-code').querySelector('pre code');
            } else if (this.closest('.tab-content')) {
                codeBlock = this.closest('.tab-content').querySelector('pre code');
            }
            
            if (codeBlock) {
                const codeText = codeBlock.textContent;
                copyToClipboard(codeText, this);
            }
        });
    });
}

// Copy text to clipboard
function copyToClipboard(text, button) {
    navigator.clipboard.writeText(text).then(() => {
        showCopySuccess(button);
    }).catch(err => {
        console.error('Failed to copy text: ', err);
        fallbackCopyToClipboard(text, button);
    });
}

// Fallback copy method for older browsers
function fallbackCopyToClipboard(text, button) {
    const textArea = document.createElement('textarea');
    textArea.value = text;
    document.body.appendChild(textArea);
    textArea.focus();
    textArea.select();
    
    try {
        document.execCommand('copy');
        showCopySuccess(button);
    } catch (err) {
        console.error('Fallback copy failed: ', err);
    }
    
    document.body.removeChild(textArea);
}

// Show copy success feedback
function showCopySuccess(button) {
    const originalIcon = button.innerHTML;
    const originalColor = button.style.color;
    
    button.innerHTML = '<i class="fas fa-check"></i>';
    button.style.color = 'var(--success-color)';
    
    setTimeout(() => {
        button.innerHTML = originalIcon;
        button.style.color = originalColor;
    }, 2000);
}

// Timeline animation
function initTimelineAnimation() {
    const timelineItems = document.querySelectorAll('.timeline-item');
    
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.style.opacity = '1';
                entry.target.style.transform = 'translateX(0)';
                entry.target.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
            }
        });
    }, { threshold: 0.1 });
    
    timelineItems.forEach((item, index) => {
        item.style.opacity = '0';
        item.style.transform = index % 2 === 0 ? 'translateX(-50px)' : 'translateX(50px)';
        observer.observe(item);
    });
}

// Typewriter effect for hero title
function initTypewriterEffect() {
    const heroTitle = document.querySelector('.hero-title');
    if (!heroTitle) return;
    
    const gradientText = document.querySelector('.title-gradient');
    if (!gradientText) return;
    
    const originalText = gradientText.textContent;
    gradientText.textContent = '';
    
    let i = 0;
    
    function typeWriter() {
        if (i < originalText.length) {
            gradientText.textContent += originalText.charAt(i);
            i++;
            setTimeout(typeWriter, 100);
        }
    }
    
    // Start typewriter effect after a short delay
    setTimeout(typeWriter, 1000);
}

// Scroll animations for sections
function initScrollAnimations() {
    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
    };

    const sectionObserver = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('fade-in-visible');
            }
        });
    }, observerOptions);

    // Observe all sections
    const sections = document.querySelectorAll('.section, .hero');
    sections.forEach(section => {
        section.classList.add('fade-in');
        sectionObserver.observe(section);
    });

    // Observe feature items
    const featureItems = document.querySelectorAll('.feature-item, .concept-card, .pattern-card, .practice-item');
    featureItems.forEach(item => {
        item.classList.add('fade-in');
        sectionObserver.observe(item);
    });
}

// Basic syntax highlighting
function initCodeHighlighting() {
    const codeBlocks = document.querySelectorAll('code');
    
    codeBlocks.forEach(code => {
        const codeText = code.textContent;
        
        // Basic syntax highlighting for HCL
        if (code.classList.contains('language-hcl')) {
            let highlighted = codeText
                .replace(/(#.*$)/gm, '<span class="code-comment">$1</span>')
                .replace(/(resource|provider|output|variable|data|module)\s+/g, '<span class="code-keyword">$1</span> ')
                .replace(/(aws_[a-z_]+)/g, '<span class="code-type">$1</span>')
                .replace(/(["'][^"']*["'])/g, '<span class="code-string">$1</span>')
                .replace(/(\b\d+\b)/g, '<span class="code-number">$1</span>');
                
            code.innerHTML = highlighted;
        }
        
        // Basic syntax highlighting for YAML
        if (code.classList.contains('language-yaml')) {
            let highlighted = codeText
                .replace(/(^.*:)/gm, '<span class="code-key">$1</span>')
                .replace(/( - )/g, '<span class="code-keyword">$1</span>')
                .replace(/(name|hosts|become|tasks|handlers|vars|roles)/g, '<span class="code-keyword">$1</span>')
                .replace(/(["'][^"']*["'])/g, '<span class="code-string">$1</span>');
                
            code.innerHTML = highlighted;
        }
        
        // Basic syntax highlighting for bash
        if (code.classList.contains('language-bash')) {
            let highlighted = codeText
                .replace(/(terraform|ansible)[\s\w-]*/g, '<span class="code-command">$1</span>')
                .replace(/(init|plan|apply|destroy|playbook)/g, '<span class="code-keyword">$1</span>')
                .replace(/(#.*$)/gm, '<span class="code-comment">$1</span>');
                
            code.innerHTML = highlighted;
        }
    });
}

// Add CSS for syntax highlighting
function addSyntaxHighlightingCSS() {
    const style = document.createElement('style');
    style.textContent = `
        .code-comment { color: #6A9955; }
        .code-keyword { color: #569CD6; }
        .code-type { color: #4EC9B0; }
        .code-string { color: #CE9178; }
        .code-number { color: #B5CEA8; }
        .code-key { color: #9CDCFE; }
        .code-command { color: #DCDCAA; }
    `;
    document.head.appendChild(style);
}

// Call syntax highlighting CSS
addSyntaxHighlightingCSS();

// Utility function to scroll to section
function scrollToSection(sectionId) {
    const element = document.getElementById(sectionId);
    if (element) {
        const offsetTop = element.offsetTop - 80;
        window.scrollTo({
            top: offsetTop,
            behavior: 'smooth'
        });
    }
}

// Utility function to open tab
function openTab(tabId) {
    const tabBtns = document.querySelectorAll('.tab-btn');
    const tabContents = document.querySelectorAll('.tab-content');
    
    tabBtns.forEach(btn => btn.classList.remove('active'));
    tabContents.forEach(content => content.classList.remove('active'));
    
    // Find and activate the correct tab button
    tabBtns.forEach(btn => {
        if (btn.textContent.toLowerCase().includes(tabId.split('-')[0])) {
            btn.classList.add('active');
        }
    });
    
    const targetTab = document.getElementById(tabId);
    if (targetTab) {
        targetTab.classList.add('active');
    }
}

// Utility function to copy code
function copyCode(elementId) {
    const codeElement = document.getElementById(elementId);
    if (codeElement) {
        const codeText = codeElement.textContent;
        const copyBtn = codeElement.closest('.content-code, .tab-content').querySelector('.copy-btn');
        copyToClipboard(codeText, copyBtn);
    }
}

// Navbar background on scroll
window.addEventListener('scroll', function() {
    const navbar = document.querySelector('.navbar');
    if (navbar) {
        if (window.scrollY > 100) {
            navbar.style.background = 'rgba(255, 255, 255, 0.98)';
            navbar.style.boxShadow = 'var(--shadow-md)';
        } else {
            navbar.style.background = 'rgba(255, 255, 255, 0.95)';
            navbar.style.boxShadow = 'none';
        }
    }
});

// Handle page load animations
window.addEventListener('load', function() {
    // Add loaded class to body for any post-load animations
    document.body.classList.add('loaded');
    
    // Ensure hero section is visible
    const hero = document.querySelector('.hero');
    if (hero) {
        hero.classList.add('fade-in-visible');
    }
});

// Keyboard navigation support
document.addEventListener('keydown', function(e) {
    // ESC key closes mobile menu
    if (e.key === 'Escape') {
        const navMenu = document.querySelector('.nav-menu');
        if (navMenu && navMenu.classList.contains('active')) {
            navMenu.classList.remove('active');
            resetMobileMenu();
        }
    }
    
    // Tab key navigation for code blocks
    if (e.key === 'Tab' && e.target.tagName === 'CODE') {
        e.preventDefault();
        const selection = window.getSelection();
        const range = selection.getRangeAt(0);
        
        // Insert tab character
        const tabNode = document.createTextNode('    ');
        range.insertNode(tabNode);
        range.setStartAfter(tabNode);
        range.setEndAfter(tabNode);
        selection.removeAllRanges();
        selection.addRange(range);
    }
});

// Performance optimization: Debounce scroll events
function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}

// Optimized scroll handler
const optimizedScrollHandler = debounce(function() {
    // Any scroll-based calculations can go here
}, 10);

window.addEventListener('scroll', optimizedScrollHandler);

// Error handling for missing elements
function safeQuerySelector(selector) {
    try {
        return document.querySelector(selector);
    } catch (error) {
        console.warn(`Element not found: ${selector}`);
        return null;
    }
}

// Initialize all features safely
function safeInit(initFunction, functionName) {
    try {
        initFunction();
    } catch (error) {
        console.error(`Error in ${functionName}:`, error);
    }
}

// Export functions for global access (if needed)
window.scrollToSection = scrollToSection;
window.openTab = openTab;
window.copyCode = copyCode;

console.log('DevOps Blog initialized successfully! 🚀');