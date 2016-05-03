(function() {
    $("#two").waypoint(function(direction) {
        if (direction == 'up') {
            // $("#slider").animate({
            //     'opacity': 0.90,
            //     'background': '#FFF',
            //     'height': '50%',
            // }, 'slow').animate({
            //     'opacity': 0.45,
            //     'height': '0',
            // }, 'slow').animate({
            //     'width': '0',
            //     'top': '0',
            //     'opacity': 0,
            // }, 'fast');
            $("#slider").animate({
                'opacity': 0.10,
                'height': '50%',
                'width': '100%',
            }, 'slow', 'linear').animate({
                'height': '0',
                'width': '0',
                'opacity': 0,
            }, 'slow');
        } else {
            $("#slider").animate({
                'opacity': -1,
                'width': '100%',
                'top': '38%',
                'background': '#FFF'
            }, 'fast').animate({
                'height': '100%',
                'opacity': 0.50,
            }, 'slow', 'linear').animate({
                'opacity': 1,
            }, 'slow', 'linear');
        }
        return false;
    });
    var slideImgs = $('#slideImgs').children('a'),
        totalHeight = 0,
        sectionId = 1;
    $('#slideImgs').children('a').css({
        'z-index': 2
    });
    // slideImgs.each(function() {
    //     var $this = $(this),
    //         img = $this.children('img'),
    //         heightOgimg = img.height();
    //     totalHeight = totalHeight + heightOgimg;
    //     // if (sectionId == 1) {
    //     //     $(".hiddensec").css({
    //     //         'height': heightOgimg + 'px',
    //     //         'background': 'blue'
    //     //     });
    //     // }
    //     console.log(heightOgimg);
    // });
    slideImgs.eq(0).siblings('a').css({
        'left': '100%',
        'opacity': '0'
    });
    $("#three").waypoint(function(direction) {
        if (direction == 'up') {
            slideImgs.eq(1).animate({
                'left': '100%',
                'opacity': '0'
            }, 500);
            $("#tag").animate({
                opacity: 0.5
            }, 300).animate({
                opacity: 1
            }, 300);
            setTimeout(function() {
                $("#tag").text('1. Anwser some simple questions.');
            }, 300);
        } else {
            slideImgs.eq(1).animate({
                'left': '0',
                'opacity': '1'
            }, 500);
            $("#tag").animate({
                opacity: 0.5
            }, 300).animate({
                opacity: 1
            }, 300);
            setTimeout(function() {
                $("#tag").text('2. Review the proposals.');
            }, 300);
        }
        return false;
    });
    $("#four").waypoint(function(direction) {
        if (direction == 'up') {
            slideImgs.eq(2).animate({
                'left': '100%',
                'opacity': '0'
            }, 500);
            $("#tag").animate({
                opacity: 0.5
            }, 300).animate({
                opacity: 1
            }, 300);
            setTimeout(function() {
                $("#tag").text('2. Review the proposals.');
            }, 300);
        } else {
            slideImgs.eq(2).animate({
                'left': '0',
                'opacity': '1'
            }, 500);
            $("#tag").animate({
                opacity: 0.5
            }, 300).animate({
                opacity: 1
            }, 300);
            setTimeout(function() {
                $("#tag").text('3. Securely pay for video.');
            }, 300);
        }
        return false;
    });
    $("#infour").waypoint(function(direction) {
        if (direction == 'up') {
            // $("#slider").animate({
            //     'opacity': 1,
            //     'height': '100%',
            //     'width': '100%',
            //     'top': '38%',
            //     'background': '#FFF'
            // }, 'fast');
            // 
            $("#slider").animate({
                'opacity': -1,
                'width': '100%',
                'height': '100%',
                'top': '38%',
            }, 'slow').animate({
                'opacity': 0.50,
                'background': '#FFF',
            }, 'fast').animate({
                'opacity': 1,
            }, 'fast', 'linear');
            $("#tag").text('3. Securely pay for video.');
        } else {
            $("#tag").text('');
            // $("#slider").animate({
            //     'opacity': 0,
            //     'background': '#FFF',
            //     'width': '0',
            //     'height': '0',
            //     'top': '0',
            // }, 'fast');
            // setTimeout(function() {
            //     $('#workClick').trigger('click');
            // }, 800);
            $("#slider").animate({
                'opacity': 0,
                'height': '50%',
                'width': '100%',
            }, 'slow', 'linear').animate({
                'opacity': 0,
                'height': '0px',
                'width': '0px',
            }, 'slow', 'linear');
        }
        return false;
    });
})();

$(document).ready(function() {
    $("#slider").css("position", "absolute");
});

$(window).scroll(function() {
    var orig = $(window).scrollTop(),
        scrooler = orig - 50;
    $("#slider").css("top", scrooler + "px");
});