import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';


class Variables
{
  User firebaseuser;
  User provider;
 
  String user_type;
  FirebaseAuth admin_auth;
  FirebaseAuth provider_auth;
  String session_ID;
  String service_ID;
  int cartstatus;
  int carttotal;
  String userid;
  int cart_updated;
  

 


  static final Variables _singleton = new Variables._internal();

  factory Variables() {
    return _singleton;
  }

  void setUserId(String userid)
  {
    this.userid = userid;
  }

  void setCartUpdateStatus(int cart_updated)
  {
    this.cart_updated=cart_updated;
  }

  

  
  void setFIrebaseUser(User firebaseuser)
  {
    this.firebaseuser = firebaseuser;
  }

  void setAdminAuth(FirebaseAuth admin_auth)
  {
    this.admin_auth = admin_auth;

  }

  void setProviderAuth(FirebaseAuth provider_auth)
  {
    this.provider_auth = provider_auth;
  }

  void setProvider(User provider)
  {
    this.provider = provider;
  }

  void setUsertype(String user_type)
  {
    this.user_type=user_type;
  }

  void setSessionId(String session_ID)
  {
    this.session_ID=session_ID;
  }
  void setServiceID(String service_ID)
  {
    this.service_ID=service_ID;
  }
  void setCartStatus(int cartstatus)
  {
    this.cartstatus=cartstatus;
  }
  void setCartTotal(int carttotal)
  {
    this.carttotal=carttotal;
  }

  Variables._internal();

}