// Riverbed Community Toolkit
// IMS - SPA
// Copyright (c) 2020 Riverbed Technology, Inc.

$('.nav a').on('click', function() {
        var $this = $(this);
        document.getElementById('activity_state').innerHTML = $this.attr("id")+"-Start"

        var xhr = new XMLHttpRequest();
        xhr.open("GET", "Data-"+$this.attr("id")+".json");
        xhr.send();

        xhr.onload = function() {
            document.getElementById('activity_state').innerHTML = $this.attr("id")+"-Complete"
        };

        xhr.onerror = function() {
            document.getElementById('activity_state').innerHTML = $this.attr("id")+"-Error"
        };

})