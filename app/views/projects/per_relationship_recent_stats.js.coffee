content = $('<%= escape_javascript(render(partial: 'stats', locals: {project: @project, relationship: @relationship}) ) %>')
$('#graphs').html content
