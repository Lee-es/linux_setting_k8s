-- ============================================================================
-- = LunarVim 기본 설정 파일 (config.lua)
-- ============================================================================
-- LunarVim은 기본 설정을 lvim 전역 변수로 관리합니다.

-- ============================================================================
-- =  기본 옵션 및 색상 스킴 설정
-- ============================================================================
-- 원하는 컬러스킴 설정 (예: "jellybeans" 사용 - 해당 컬러스킴이 설치되어 있어야 합니다)
lvim.colorscheme = "jellybeans"

-- Vim 기본 옵션 설정 (init.vim의 set 옵션을 Lua로 변환)
vim.opt.tabstop = 8              -- 탭 폭: 8 칸
vim.opt.shiftwidth = 8           -- 자동 들여쓰기 이동 거리
vim.opt.softtabstop = 8          -- Insert 모드에서의 탭 폭
vim.opt.number = true            -- 줄 번호 표시
vim.opt.showmatch = true         -- 괄호 매칭 강조
vim.opt.path:append("**")        -- gf 명령 시 하위 디렉토리까지 포함
vim.opt.hlsearch = true          -- 검색 시 강조
vim.opt.showtabline = 2          -- 항상 탭 라인 표시
vim.opt.colorcolumn = "80"       -- 80번째 열 기준선 표시
vim.opt.inccommand = "nosplit"   -- live substitute 미리보기 (Neovim)
vim.opt.clipboard = "unnamedplus" -- 시스템 클립보드 연동
vim.opt.termguicolors = true     -- TrueColor 활성화
vim.opt.mouse = "a"              -- 마우스 지원
vim.opt.viewoptions:remove("options")  -- 뷰(view) 저장 시 options 제외
if vim.fn.has("syntax") == 1 then
  vim.cmd("syntax on")
end

-- ============================================================================
-- =  하이라이트(Highlight) 설정
-- ============================================================================
-- 배경 및 줄 번호 하이라이트 설정
vim.cmd("highlight Normal guibg=NONE")
vim.cmd("highlight EndOfBuffer guibg=NONE")
vim.cmd("highlight LineNr guibg=NONE gui=bold guifg=white")
vim.cmd("highlight ColorColumn guibg=White")

-- ============================================================================
-- =  사용자 함수 정의
-- ============================================================================
-- 탭 사이즈 변경 함수 (사용 예: :lua SetTab(4))
function SetTab(size)
  vim.cmd("set shiftwidth=" .. size)
  vim.cmd("set tabstop=" .. size)
  vim.cmd("set softtabstop=" .. size)
end

-- ============================================================================
-- =  자동 명령(autocmd) 설정
-- ============================================================================
-- 터미널 버퍼 진입 시 줄 번호 제거
vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "term://*",
  callback = function()
    vim.opt_local.number = false
  end,
})

-- *.S 파일 열 때 파일 형식을 GAS로 설정
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
  pattern = {"*.S"},
  callback = function()
    vim.cmd("set ft=gas")
  end,
})

-- .c, .h 파일 편집 시 뷰(view) 저장 및 로드 (커서 위치 유지)
vim.api.nvim_create_autocmd("BufWinLeave", {
  pattern = {"*.c", "*.h"},
  callback = function()
    vim.cmd("mkview")
  end,
})
vim.api.nvim_create_autocmd("BufWinEnter", {
  pattern = {"*.c", "*.h"},
  callback = function()
    vim.cmd("silent! loadview")
  end,
})

-- c, cpp 파일 진입 시 줄 번호 활성화, 나갈 시 비활성화
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*",
  callback = function()
    local ft = vim.bo.filetype
    if ft == "c" or ft == "cpp" then
      vim.opt.number = true
    end
  end,
})
vim.api.nvim_create_autocmd("BufLeave", {
  pattern = "*",
  callback = function()
    local ft = vim.bo.filetype
    if ft == "c" or ft == "cpp" then
      vim.opt.number = false
    end
  end,
})

-- ============================================================================
-- =  플러그인 설정 (추가 플러그인)
-- ============================================================================
-- LunarVim은 기본적으로 packer를 사용하며, 이미 많은 플러그인이 사전 구성되어 있습니다.
-- 아래는 init.vim에서 사용한 플러그인 중 LunarVim 기본 구성에 없는 항목을 추가하는 예입니다.
lvim.plugins = {
  { "neoclide/coc.nvim", branch = "release" },         -- 강력한 자동완성 플러그인 (주의: LunarVim 기본 LSP와 중복될 수 있음)
  { "preservim/tagbar" },                                 -- 코드 구조(태그) 뷰어
  { "preservim/nerdtree" },                               -- 파일 탐색기
  { "nanotech/jellybeans.vim" },                          -- 컬러스킴
  { "vim-airline/vim-airline" },                          -- vim-airline (기본은 lualine 사용)
  { "vim-airline/vim-airline-themes" },                   -- vim-airline 테마
  { "ronakg/quickr-cscope.vim" },                         -- CScope 지원
  { "ctrlpvim/ctrlp.vim" },                               -- 빠른 파일 탐색
  { "svermeulen/vim-cutlass" },                           -- 잘라내기 명령어 개선
  { "Shirk/vim-gas" },                                    -- GNU Assembler 문법 하이라이팅
}

-- ============================================================================
-- =  키 매핑 설정 (MacBook 환경 최적화)
-- ============================================================================
-- 입력 모드: 'jk' 또는 'kj'로 Insert 모드에서 <ESC> 전환
lvim.keys.insert_mode["jk"] = "<ESC>"
lvim.keys.insert_mode["kj"] = "<ESC>"

-- 일반 모드(명령 모드) 키 매핑
lvim.keys.normal_mode["<F1>"] = ":NERDTreeToggle<CR>:TagbarToggle<CR>"
lvim.keys.normal_mode["<C-j>"] = ":tabprevious<CR>"
lvim.keys.normal_mode["<C-k>"] = ":tabnext<CR>"
lvim.keys.normal_mode["<C-h>"] = ":bp<CR>"
lvim.keys.normal_mode["<C-l>"] = ":bn<CR>"
lvim.keys.normal_mode["<S-h>"] = ":bp<bar>sp<bar>bn<bar>bd<CR>"
lvim.keys.normal_mode["<S-l>"] = ":bp<bar>sp<bar>bn<bar>bd<CR>"
lvim.keys.normal_mode["<C-w>t"] = ":NERDTreeFocus<CR>"

-- F2: 터미널 창 생성 후 크기 조정 및 고정
lvim.keys.normal_mode["<F2>"] = ":botright new<CR>:terminal<CR><ESC>:resize 10<CR>:set winfixheight<CR>:set nonu<CR>"

-- F9: 자동 주석 삽입 (현재 날짜 포함)
lvim.keys.normal_mode["<F9>"] = "<ESC>o/*<CR> * IAMROOT, " .. os.date("%Y.%m.%d") .. ": <CR>*/<CR><ESC><UP><UP><END>"

-- 터미널 모드 키 매핑 (vim.api.nvim_set_keymap 사용)
vim.api.nvim_set_keymap("t", "<C-w>", "<ESC><C-w>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("t", "jk", "<ESC>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("t", "kj", "<ESC>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("t", "<ESC>", "<C-\\><C-n>", { noremap = true, silent = true })

-- ============================================================================
-- =  coc.nvim 및 자동완성 관련 설정
-- ============================================================================
-- 주의:
-- LunarVim은 기본적으로 nvim-cmp와 내장 LSP 시스템(예: built-in LSP, null-ls 등)을 사용합니다.
-- coc.nvim을 추가하면 LSP 및 자동완성 기능이 중복되어 충돌할 수 있습니다.
-- 필요한 경우 coc.nvim 설정을 비활성화하거나 LunarVim 내장 LSP와 조정하여 사용하시기 바랍니다.
vim.opt.signcolumn = "number"  -- signcolumn과 줄 번호 병합

-- <S-TAB> 키를 이용해 자동완성 메뉴 내 이전 항목 선택 (coc 공식 문서 참고)
vim.api.nvim_set_keymap("i", "<S-TAB>",
  'pumvisible() ? "<C-p>" : "<C-h>"',
  { expr = true, noremap = true, silent = true })

-- <C-Space>를 눌러 coc.nvim 자동완성 메뉴 호출
if vim.fn.has("nvim") == 1 then
  vim.api.nvim_set_keymap("i", "<C-Space>", "coc#refresh()", { expr = true, noremap = true, silent = true })
else
  vim.api.nvim_set_keymap("i", "<C-@>", "coc#refresh()", { expr = true, noremap = true, silent = true })
end

-- 코드 참조(References) 단축키: gr
vim.api.nvim_set_keymap("n", "gr", "<Plug>(coc-references)", { silent = true })

-- 커서 위치에서 토큰 강조 (비동기)
vim.api.nvim_create_autocmd("CursorHold", {
  callback = function()
    vim.fn.CocActionAsync('highlight')
  end,
})

-- ============================================================================
-- =  nvim-treesitter 설정 (LunarVim 기본 설정과 중복되지 않도록)
-- ============================================================================
lvim.builtin.treesitter.ensure_installed = "maintained"
lvim.builtin.treesitter.highlight.enable = true
lvim.builtin.treesitter.highlight.additional_vim_regex_highlighting = true

-- ============================================================================
-- =  Tagbar 설정
-- ============================================================================
vim.g.tagbar_position = "rightbelow"

-- ============================================================================
-- =  vim-airline 설정 (LunarVim 기본은 lualine이지만 기존 설정 반영)
-- ============================================================================
vim.g.airline_powerline_fonts = 1
vim.g.airline_theme = "luna"
vim.g["airline#extensions#tabline#formatter"] = "unique_tail"
vim.g["airline#extensions#tabline#enabled"] = 1
vim.g["airline#extensions#tabline#show_tabs"] = 1

-- ============================================================================
-- =  NERDTree 설정
-- ============================================================================
vim.g.NERDTreeWinSize = 30

-- ============================================================================
-- =  vim-cutlass 설정 (잘라내기 단축키 재정의)
-- ============================================================================
vim.api.nvim_set_keymap("n", "c", "d", { noremap = true, silent = true })
vim.api.nvim_set_keymap("x", "c", "d", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "cc", "dd", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "C", "Dv", { noremap = true, silent = true })

-- ============================================================================
-- =  vim-gas 
-- ============================================================================
-- vim-gas 플러그인은 기본적으로 파일 형식에 맞춰 하이라이팅을 제공합니다.
-- 추가 설정이 필요하면 여기에 작성하세요.

-- ============================================================================
-- =  마무리 및 참고 사항
-- ============================================================================
-- 사용 중 필요에 따라 추가 수정 및 최적화를 진행하시기 바랍니다.
-- LunarVim을 실행한 후, :PackerSync (또는 LunarVim에서 제공하는 플러그인 동기화 명령어)를 실행하여 플러그인 설치 및 업데이트를 진행합니다.