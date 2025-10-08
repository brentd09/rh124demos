syntax on
filetype plugin indent on
autocmd BufRead,BufNewFile *.sh set filetype=sh
autocmd BufNewFile *.sh call append(0, '#!/bin/bash')
augroup ansible_playbook
  autocmd!
  autocmd BufNewFile *.yml,*.yaml call append(0, [
        \ '---',
        \ '- hosts: all',
        \ '  become: yes',
        \ '  tasks:',
        \ '    - name: Example task',
        \ '      debug:',
        \ '        msg: "Hello, Ansible!"'
        \ ])
augroup END
set tabstop=2 
set shiftwidth=2
set softtabstop=2
set expandtab   
set autoindent
set smartindent
set showmatch

