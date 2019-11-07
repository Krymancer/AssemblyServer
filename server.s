.section .rodata
 
port:
    .int    1234
    
startMsg:
    .asciz  "Starting Local Server on localhost:%u...\n"
    
httpBase:
    .asciz  "HTTP/1.0 200\r\nContent-type:text/html\r\n\r\n%s"
    
htmlBase:
    .asciz  "<html><head><title>%s</title></head><body>%s</body></html>"
    
htmlTitle:
    .asciz  "Assembly Rules."
    
htmlBody:
    .asciz  "<h1>Hello, world!</h1><h2>You are visitor #%u</h2><p>%s</p>"
    
paragraph:
    .asciz  "Web rendered dynamically by x86 assembly."
    
httpResponse404:
    .asciz  "HTTP/1.0 404 Not Found\r\n\r\n"
    
httpRequestHeader:
    .asciz  "GET / HTTP/"
    
    
.section .data
 
count:
    .int    0
    
buf:
    .asciz  "GET / HTTP/"

.text
 
.global main
main:
    push    %ebp
    movl    %esp, %ebp
    sub     $28, %esp
    
    movl    port, %eax
    
    movl    %eax, 4(%esp)
    movl    $startMsg, (%esp)
    call    printf
    
    call    m_listen
    
    movl    %eax, -4(%ebp)
    
repeat:
    movl    -4(%ebp), %eax
    
    movl    $0, 8(%esp)
    movl    $0, 4(%esp)
    movl    %eax, (%esp)
    call    accept
    
    movl    %eax, -8(%ebp)
    
    movl    $11, 8(%esp)
    movl    $buf, 4(%esp)
    movl    %eax, (%esp)
    call    read
    
    movl    $11, 8(%esp)
    movl    $httpRequestHeader, 4(%esp)
    movl    $buf, (%esp)
    call    strncmp
    
    cmp     $0, %eax
    jne     http404
    
    call    construct_response
    
    movl    %eax, -12(%ebp)
    
    movl    %eax, (%esp)
    call    strlen
    
    movl    %eax, -16(%ebp)
    
    movl    -8(%ebp), %eax
    movl    -12(%ebp), %ebx
    movl    -16(%ebp), %ecx
    
    movl    %ecx, 8(%esp)
    movl    %ebx, 4(%esp)
    movl    %eax, (%esp)
    call    write
    
    movl    -12(%ebp), %eax
    
    movl    %eax, (%esp)
    call    destroy_response
    
    jmp     cleanup
    
http404:
    movl    -8(%ebp), %eax
    
    movl    $26, 8(%esp)
    movl    $httpResponse404, 4(%esp)
    movl    %eax, (%esp)
    call    write
    
cleanup:
    movl    -8(%ebp), %eax
    
    movl    $2, 4(%esp)
    movl    %eax, (%esp)
    call    shutdown
    
    movl    -8(%ebp), %eax
    
    movl    %eax, (%esp)
    call    close
    
    jmp     repeat
    
    movl    $1, %eax
    
    leave
    ret
    
    
m_listen:              
    push    %ebp
    movl    %esp, %ebp
    
    subl    $56, %esp
    movl    $0, 8(%esp)
    movl    $1, 4(%esp)
    movl    $2, (%esp)
    call    socket
    
    movl    %eax, -12(%ebp)
    movl    $16, 8(%esp)
    movl    $0, 4(%esp)
    leal    -28(%ebp), %eax
    movl    %eax, (%esp)
    call    memset
    
    movw    $2, -28(%ebp)
    movl    $0, -24(%ebp)
    movl    port, %eax
    movzwl  %ax, %eax
    movl    %eax, (%esp)
    call    htons
    
    movw    %ax, -26(%ebp)
    movl    $16, 8(%esp)
    leal    -28(%ebp), %eax
    movl    %eax, 4(%esp)
    movl    -12(%ebp), %eax
    movl    %eax, (%esp)
    call    bind
    
    movl    $16, 4(%esp)
    movl    -12(%ebp), %eax
    movl    %eax, (%esp)
    call    listen
    
    movl    -12(%ebp), %eax
    
    leave
    ret
    
    
construct_response:
    push    %ebp
    movl    %esp, %ebp
    sub     $28, %esp
    
    add     $1, count
    
    leal    -4(%ebp), %eax
    movl    count, %ebx
    
    movl    $paragraph, 12(%esp)
    movl    %ebx, 8(%esp)
    movl    $htmlBody, 4(%esp)
    movl    %eax, 0(%esp)
    call    asprintf
    
    leal    -8(%ebp), %eax
    movl    -4(%ebp), %ebx
    
    movl    %ebx, 12(%esp)
    movl    $htmlTitle, 8(%esp)
    movl    $htmlBase, 4(%esp)
    movl    %eax, (%esp)
    call    asprintf
    
    leal    -12(%ebp), %eax
    movl    -8(%ebp), %ebx
    
    movl    %ebx, 8(%esp)
    movl    $httpBase, 4(%esp)
    movl    %eax, (%esp)
    call    asprintf
    
    movl    -4(%ebp), %eax
    
    movl    %eax, (%esp)
    call    free    
    
    movl    -8(%ebp), %eax
    
    movl    %eax, (%esp)
    call    free    
    
    movl    -12(%ebp), %eax
    
    leave
    ret
    
    
destroy_response:
    push    %ebp
    movl    %esp, %ebp
    
    movl    8(%ebp), %eax
    push    %eax
    call    free
    
    leave
    ret
