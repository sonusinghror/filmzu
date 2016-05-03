$( document ).ready(function() {

  if ( $( ".proposal_close_link" ).length ) {
    $('.proposal_close_link').live( "click", function() {
      $("#light").hide();
      $("#fade").hide();
    })
  }

  if ( $(".clear-message").length ) {
    $(".clear-message").click(function() {
      if ($(".reply-textbox").val() != "") {
        $(".reply-textbox").val("");
      }
    });
  }

  if ( $(".client-message-reply").length ) {
    $(document).on('keydown', '.reply-textbox', function(e) {
      if(e.keyCode == 13 && (e.metaKey || e.ctrlKey)) {
        $(".client-message-reply").trigger( "click" );
      }
    })
  }

  if ( $("#attach_file").length ) {
    $('#attach_file').click(function() {
      console.log('clicked');
      $('#message_attach_proposal_file').click();
      return false;
    })
  }

  if ( $("#message_attach_proposal_file").length ) {
    $('#message_attach_proposal_file').change(function() {
      var errors = "";
      var ext = $('#message_attach_proposal_file').val().split('.').pop().toLowerCase();
      if (this.files[0].size > 5000000) {
        errors += "File size should not be more than 5MB. "
      }
      if ($.inArray(ext, ['doc', 'docx', 'pdf']) == -1) {
        $('#message_attach_proposal_file').val('');
        $('#message_attach_proposal_file').replaceWith($('#message_attach_proposal_file').val('').clone(true));
        errors += "Attachments of type doc, docx and pdf are only allowed."
      } else {
        var pattern = /\\/;
        $('#message_attachment_detail').html($('#message_attach_proposal_file').val().split(pattern).slice(-1)[0]);
        $('#message_attachment_detail').css('color', '#000');
      }
      if ( errors != '' ) {
        $('#message_attachment_detail').html(errors);
        $("#message_delete_attachment").show();
        $('#message_attachment_detail').css('color', 'red');
        return false;
      }
      $("#message_delete_attachment").show();
    })
  }

  if ( $("#message_delete_attachment").length ) {
    $("#message_delete_attachment").click(function(){
      $('#message_attach_proposal_file').val('');
      $('#message_attach_proposal_file').replaceWith($('#message_attach_proposal_file').val('').clone(true));
      $('#message_attachment_detail').html('');
      $("#message_delete_attachment").hide();
      return false;
    })
  }

  if ( $(".feedbacks-display").length ) {
    $(".feedbacks-display").click(function(){
      $(".projects-listing").hide();
      $(".feedbacks-listing").show();
      $(".feedbacks-display").toggleClass('deco', true );
      $(".projects-display").toggleClass('deco', false );
    });
  }

  if ( $(".projects-display").length ) {
    $(".projects-display").click(function(){
      $(".projects-listing").show();
      $(".feedbacks-listing").hide();
      $(".feedbacks-display").toggleClass('deco', false );
      $(".projects-display").toggleClass('deco', true );
    });
  }

});

function preview_project_proposal(profile_image,user_name,location,project_name) {
  $("#light").show();
  $("#fade").show();
  var months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'June',
'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  var current_date = new Date();
  var mid='AM';
  var hours = (current_date.getHours()+24-2)%24;
  if (hours > 12){
    mid='PM';
  }
  var human_readable_date = current_date.getDate() + " " + months[current_date.getMonth()] + ", " + current_date.getHours() + ":" + current_date.getMinutes() + " " + mid;
  var cover_letter = $(".big-areaBox").val();
  var start_date = $("#milestone_start_date").val();
  var end_date = $("#milestone_end_date").val();
  if ($("#attach_proposal_file").val() == "") {
    var attachment_box = "";
  }
  else {
   var file_name = $("#attach_proposal_file").val().split('/').pop().split('\\').pop();
   var attachment_box = "<div class='attachments-box'><div class='clearfix nmt row1'><div class='attach-text fl'><img alt='Blank-img' class='attch-icon' src='javascript:void(0)'>" + file_name + "</div></div></div>";
  }
  var file_name = $("#attach_proposal_file").fileName;
  var milestones_data = ""
  $( ".milestones_dates" ).each(function (index){
    var title = $("#title_"+$(this).attr('id').split('_')[2]).val();
    var date = $("#milestones_date_"+$(this).attr('id').split('_')[2]).val();
    var amount = $("#milestone_amount_"+$(this).attr('id').split('_')[2]).val();
    var milestone_data = "<div><p class='first'>" + title + "</p><p class='rest'>" + date + "</p><p class='rest'>" + amount + "</p></div>"
    milestones_data = milestones_data + milestone_data;
  });
  $("#light").html("<div class='email-detail-box fl'><div class='email-add clearfix'><h3 class='sub-line fl'>Project Proposal Preview</h3><span class='attach-num fr'></span></div><div class='subject-box clearfix'><div class='thumb-box fl'><img alt='Tiny_jerry' height='57' src='" + profile_image + "' width='57'></div><div class='subject-cpart fl'><div class='sub-title clearfix'><h4 class='fl'>" + user_name + "</h4><span class='gray-time-box fr'>" + human_readable_date + "<img alt='Blank-img' class='gray-clock-icon' src='/assets/blank-img.png'></span></div><ul class='gray-status-box clearfix'><li><img alt='Blank-img' class='loc-icon' src='/assets/blank-img.png'>" + location + "</li></ul><div class='des-text'><div class='project-desc'><p><span class='flabel pr'>Project:</span><span class='field'>" + project_name + "</span></p><p><span class='flabel pr'>Cover Letter:</span><span class='field'>" + cover_letter + "</span></p><p><span class='flabel'>Dates:</span><span class='field'>" + start_date + "<br>" + end_date + "</span></p></div><div class='proposal-content'><div class='first-row'><p class='first'>Proposed Milestone</p><p class='rest'>Delivery Date</p><p class='rest'>Amount</p></div><div class='next-row'>" + milestones_data + "</div></div></div></div></div>" + attachment_box + "<br><a href = 'javascript:void(0)' class='proposal_close_link_' onclick = '$(\"#light\").hide(); $(\"#fade\").hide();return false;'>Close Preview</a></div>");
}

function submit_report_details(user, event) {
  if( user == true ){
    var btn = $(event.target)
    btn.html('Please wait..')
    btn.attr('disabled', 'disabled')
    $(".report_cancel_btn").attr('disabled', 'disabled')
    $.ajax({
      url: '/report',
      type: 'POST',
      data: {
        entity: btn.attr('data-entity'),
        id: btn.attr('data-id'),
        reason: $('#report_entity_reason').val(),
        authenticity_token: $(".form_authenticity_token").val()
      },
      success: function(resp){
        if(resp == 'true'){
          alert('Feedback received. Thank You for helping us')
          btn.attr('disabled', false)
          btn.html('Report')
          $('#report-modal').modal('hide')
        }
      }
    });
  }
  else{
    alert('Please login to continue with the action');
    return false;
  }
}
