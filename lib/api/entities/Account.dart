class AxiosAccount {
    late String _schoolID;
    late String _userID;
    late String _userPassword;

    AxiosAccount(String schoolID, String userID, String userPassword) {
        this._schoolID = schoolID;
        this._userID = userID;
        this._userPassword = userPassword;
    }

    String get schoolID {
        return this._schoolID;
    }
    String get userID {
        return this._userID;
    }
    String get userPassword {
        return this._userPassword;
    }
    set userPassword(String pass) {
        this._userPassword = pass;
    }

    toString() {
        return "AxiosInstance(school: ${this._schoolID}, uid: ${this._userID}, password: ${this._userPassword})";
    }
}