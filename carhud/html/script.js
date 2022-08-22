$(function () {
    function display(bool) {
        if (bool) {
            $(".carhud").fadeIn();
        } else {
            $(".carhud").fadeOut();
        }
    }

    display(false)

    window.addEventListener('message', function (event) {
        var item = event.data;
        if (item.typeSH === "ui") {
            if (item.status == true) {
                display(true)
            } else {
                display(false)
            }
        }
        else if (item.action == "toggle"){
            if (item.show){
                $(".carhud").show()
            }
            else{
                $(".carhud").hide()
            }
        }
    })
})