import 'commands.dart';

class Command {
  int id = - 1;
	bool inMemory = false;
	bool updatable = false;
	String type = '';
	String name = '';
	Editor editor;

	Command(this.editor);

  void execute(){}
  void undo(){}

	Map<String,dynamic> toJson() {
		return {
      'type': this.type,
      'id': this.id,
      'name': this.name
    };
	}

	void fromJson(Map<String,dynamic> json ) {
		this.inMemory = true;
		this.type = json['type'];
		this.id = json['id'];
		this.name = json['name'];
	}
}
