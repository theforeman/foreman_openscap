function findSpoolLogs() {
    var table,
        string = 'Failed to parse Arf Report';
    $("div#table-proxy-status-logs_filter input").val(string);
    table = $('#table-proxy-status-logs').DataTable();
    table.search(string).draw();
}
