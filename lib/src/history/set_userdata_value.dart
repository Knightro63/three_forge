import "commands.dart";

class SetUserDataValueCommand extends Command {
  dynamic newValue;
  dynamic oldValue;
  String? subAttributeName;

	SetUserDataValueCommand(super.editor, [super.object, String? attributeName, this.subAttributeName , this.newValue]){
		this.attributeName = attributeName;
		this.updatable = true;

		this.oldValue = subAttributeName ==null?object?.userData[ attributeName ]:object?.userData[ attributeName ]?[subAttributeName];
    print(oldValue);
	}

	void execute() {
		if(subAttributeName == null){
      object?.userData[ attributeName! ] = this.newValue;
    }
    else{
      object?.userData[ attributeName ][subAttributeName] = this.newValue;
    }
		this.editor.dispatch();
	}

  @override
	void undo() {
    super.undo();
		if(subAttributeName == null){
      object?.userData[ attributeName! ] = this.oldValue;
    }
    else{
      object?.userData[ attributeName ][subAttributeName] = this.oldValue;
    }
		this.editor.dispatch();
	}

  @override
	void update(Command cmd) {
		this.newValue = (cmd as SetUserDataValueCommand).newValue;
	}

  @override
	Map<String,dynamic> toJson() {
		final output = super.toJson();

		output['objectUuid'] = this.object?.uuid;
		output['attributeName'] = this.attributeName;
    output['subAttributeName'] = this.subAttributeName;
		output['oldValue'] = this.oldValue;
		output['newValue'] = this.newValue;

		return output;
	}

  @override
	void fromJson(Map<String,dynamic> json ) {
		super.fromJson( json );

		this.attributeName = json['attributeName'];
    this.subAttributeName = json['subAttributeName'];
		this.oldValue = json['oldValue'];
		this.newValue = json['newValue'];
		this.object = this.editor.objectByUuid( json['objectUuid'] );
	}
}
