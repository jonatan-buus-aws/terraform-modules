data "template_file" "pgbouncer" {
    depends_on = [ var.pgbouncer_database_host ]
    
    template = file("${path.module}/pgbouncer.ini")
    vars = {
        database_host = var.pgbouncer_database_host
        pgbouncer_port = var.pgbouncer_port
    }
}
data "template_file" "userlist" {
    template = file("${path.module}/userlist.txt")
}