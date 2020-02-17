textadept.file_types.extensions.nelua = 'nelua'
textadept.editing.comment_string.nelua = '--'

textadept.run.compile_commands.nelua = function ()
   return "nelua -q -b %p", io.get_project_root()
end
textadept.run.run_commands.nelua = function ()
   return "nelua -q %p", io.get_project_root()
end
