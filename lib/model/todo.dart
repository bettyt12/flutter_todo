class ToDo {
  String? id;
  String? todoText;
  bool isDone;

  ToDo({
    required this.id,
    required this.todoText,
    this.isDone = false
  });
  

  static List<ToDo> todoList(){
    return [
      ToDo(id: '01', todoText: 'Morning excercise', isDone: true),
      ToDo(id: '02', todoText: 'Buy Groceries', isDone: true),
      ToDo(id: '03', todoText: 'Check email',  ),
      ToDo(id: '04', todoText: 'lunch'),
      ToDo(id: '05', todoText: 'dinner', isDone: false),
    ];
  }
}