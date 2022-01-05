noremap j gj
noremap k gk

noremap H ^
noremap L $

set clipboard=unnamed

unmap <Space> " Require by <Space>

exmap search obcommand editor:open-search
exmap globalSearch obcommand global-search:open
exmap searchReplace obcommand editor:open-search-replace

nmap <Space>ff :search
nmap <Space>hh :searchReplace


