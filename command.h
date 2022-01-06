//#include "command.h"
#include <iostream>
#include <cstring>
#include <jsoncpp/json/value.h>
#include <jsoncpp/json/json.h>
#include <jsoncpp/json/writer.h>
#include <fstream>
#include <cstddef>
using namespace Json;
int count_user = 0;
struct
{
    int key;
    char username_on[100];
} users[10];
int oline_users = 0;

void mod_stat_msg()
{
    Json::Value root;
    std::ifstream file("conv.json");
    file >> root;

    Json ::Value clear(root[root.size() - 1]["seen"]);
    root[root.size() - 1]["seen"] = true;

    file.close();
    std ::ofstream fout("conv_.son");
    Json::StreamWriterBuilder builder;
    const std::string json_file = Json::writeString(builder, root);
    fout << json_file;
    fout.close();
}

void add_history(char *msg, char *user1, char *user2)
{
    Json::Value root;
    std::ifstream file("conv.json");
    file >> root;

    Json::Value newUser;
    Json ::Value from;
    Json ::Value to;
    Json ::Value seen;
    Json ::Value message;
    Json ::Value stat;
    newUser["from"] = user1;
    newUser["to"] = user2;
    newUser["message"] = msg;
    newUser["seen"] = false;
    root.append(newUser);

    std::cout << root;
    file.close();
    std::ofstream out("conv.json");
    Json::StreamWriterBuilder builder;
    const std::string json_file = Json::writeString(builder, root);
    // std::cout << json_file;
    out << json_file << std::endl;
    out.close();
}

int get_stat_user(char *s)
{
    Json::Value root;
    std::ifstream file("json_obj.json");
    file >> root;
    std ::string username_s = s;

    for (int i = 0; i < root.size(); i++)
    {
        if (root[i]["username"] == username_s)
        {
            return root[i]["stat"].asInt();
        }
    }
    file.close();
    return -1;
}

void mod_stat_user(char *s, int key)
{
    Json::Value root;
    std::ifstream file("json_obj.json");
    file >> root;
    std ::string username_s = s;

    for (int i = 0; i < root.size(); i++)
    {
        if (root[i]["username"] == username_s)
        {
            // Json :: Value clear(root[i]["stat"]) ;
            root[i]["stat"] = key;
            break;
        }
    }
    file.close();
    std ::ofstream fout("json_obj.json");
    Json::StyledWriter writer;
    std ::string strJson = writer.write(root);
    fout << strJson;
    fout.close();
}

void register_user(char *username1)
{
    Json::Value root;
    std::ifstream file("json_obj.json");
    file >> root;
    file.close();
    Json::Value newUser;
    Json ::Value stat;
    newUser["username"] = username1;
    newUser["stat"] = -1;
    root.append(newUser);

    std::cout << root;
    file.close();
    std::ofstream out("json_obj.json");
    Json::StreamWriterBuilder builder;
    const std::string json_file = Json::writeString(builder, root);
    // std::cout << json_file;
    out << json_file << std::endl;
    out.close();
}
/*void readJson()
{

    Json::Value root;
    std::ifstream file("json_obj.json");
    file >> root;
    

    for (int i = 0; i < root.size(); i++)
    {
        std::cout << root[i]["username"] << std::endl;
    }
    file.close();
 
}
*/
bool verf_username(std::string username)
{
    Json::Value root;
    std::ifstream file("json_obj.json");
    file >> root;
    file.close();
    for (int i = 0; i < root.size(); i++)
    {
        std::string username_str = root[i]["username"].asString();
        if (username == username_str)
        {
            return 1;
        }
    }
    file.close();
    return 0;
}

int client_in(char *cmd)
{
    char username[100];
    if (strstr(cmd, "/login"))
    {
        strcpy(username, cmd + 7);
        if (verf_username(username) == 0)
        {
            // vom returna 1, pentru ca nu exista nici un user cu acest username
            return 1;
        }
        //returnam 0 pentru ca logarea a avut succes
        strcpy(users[count_user - 1].username_on, username);
        mod_stat_user(username, users[count_user - 1].key);
        return 0;
    }

    if (strstr(cmd, "/register"))
    {
        strcpy(username, cmd + 10);
        // std :: cout << username<<" "<< std :: endl;
        if (verf_username(username))
        {
            //returnam 2, pentru ca exista deja un user cu acest username
            return 2;
        }
        register_user(username);
        return 4;
    }

    if (strstr(cmd, "/exit"))
    {
        // returnam -1, client deconectat
        return -1;
    }

    //returnam -2, nu exista sau nu puteti utiliza aceasta coamnda
    return -2;
}

std ::string all_users()
{

    Json::Value root;
    std::ifstream file("json_obj.json");
    file >> root;

    std ::string result = "USERS : \n";
    std ::cout << "Salut" << std ::endl;
    for (int i = 0; i < root.size(); i++)
    {
        std::string username_str = root[i]["username"].asString();
        result += username_str + " \n ";
    }

    file.close();
    return result;
}

void send_msg_to(char *to_user, char *msg)
{
    int sk_to_user = get_stat_user(to_user);
    add_history(msg, users[count_user - 1].username_on, to_user);
    /*   if(sk_to_user > 0){
         mod_stat_msg();
         char result[1024];
         strcpy(result, users[count_user - 1].username_on);
         strcat(result, " : ");
         strcat(result, msg);
         send(sk_to_user, result, strlen(result), 0); 
     } */
}

std ::string history_conv(char *token)
{
    if (strcmp("all", token) == 0)
    {
        Json::Value root;
        std::ifstream file("conv.json");
        file >> root;
        std ::string result = "";
        char t[100], sep[] = " ";
        for (int i = 0; i < root.size(); i++)
        {
            Json::FastWriter fastWriter2;
            std::string output2 = fastWriter2.write(root[i]["from"]);

            Json::FastWriter fastWriter4;
            std::string output4 = fastWriter4.write(root[i]["to"]);

            std ::cout << output2.substr(1, output2.size() - 3) << std ::endl;
            if (output4.substr(1, output4.size() - 3) == users[count_user].username_on || output2.substr(1, output2.size() - 3) == users[count_user - 1].username_on)
            {
                if (output4.substr(1, output4.size() - 3) == users[count_user].username_on)
                {
                    if (result.find(output2.substr(1, output2.size() - 3)) == std ::string ::npos)
                    {
                        result += "\t \t <>" + output2.substr(1, output2.size() - 3) + "\n";
                    }
                }
                else
                {
                    if (result.find(output4.substr(1, output4.size() - 3)) == std ::string ::npos)
                    {
                        result += "\t \t <>" + output4.substr(1, output4.size() - 3) + "\n";
                    }
                }
            }
        }
        file.close();
        if (result == "")
            return "empty";

        result = "Ai vorbit pana acum cu : \n" + result;
        return result;
    }
    else
    {
        Json::Value root;
        std::ifstream file("conv.json");
        file >> root;
        std ::string result = "";
        std ::string tok = token;
        for (int i = 0; i < root.size(); i++)
        {

            Json::FastWriter fastWriter8;
            std::string output8 = fastWriter8.write(root[i]["from"]);

            Json::FastWriter fastWriter9;
            std::string output9 = fastWriter9.write(root[i]["to"]);
            std ::cout << "Am intrat si e cald !!!" << std ::endl;
            std ::cout << output8.substr(1, output8.size() - 3) << " " << token << " " << output9.substr(1, output9.size() - 3) << std ::endl;
            if ((output9.substr(1, output9.size() - 3) == users[count_user - 1].username_on && output8.substr(1, output8.size() - 3) == tok) || (output8.substr(1, output8.size() - 3) == users[count_user - 1].username_on && output9.substr(1, output9.size() - 3) == tok))
            {

                if (output8.substr(1, output8.size() - 3) == users[count_user - 1].username_on)
                {

                    Json::FastWriter fastWriter;
                    std::string output = fastWriter.write(root[i]["message"]);
                    result = result + "Me : " + output;
                }
                else
                {
                    Json::FastWriter fastWriter;
                    std::string output = fastWriter.write(root[i]["message"]);
                    result = result + " \t  \t" + output.substr(0, output.size() - 1) + " : " + token + " \n ";
                }
            }
        }
        file.close();
        if (result == "")
        {
            result = "Nu ai o conv cu acest user !";
            return result;
        }
        return "\n" + result;
    }
}

bool exist_conv(char *to_user)
{

    Json::Value root;
    std::ifstream file("conv.json");
    file >> root;
    std ::string result = "";
    for (int i = 0; i < root.size(); i++)
    {
        Json::FastWriter fastWriter2;
        std::string output2 = fastWriter2.write(root[i]["to"]);

        Json::FastWriter fastWriter4;
        std::string output4 = fastWriter4.write(root[i]["from"]);
        if (output4.substr(1, output4.size() - 3) == users[count_user].username_on || output2.substr(1, output2.size() - 3) == users[count_user].username_on)
            return 1;
    }
    file.close();
    return 0;
}

std ::string unseen_msg()
{
    Json::Value root;
    std::ifstream file("conv.json");
    file >> root;

    std ::string result;
    std ::string k = users[count_user - 1].username_on;
    for (int i = 0; i < root.size(); i++)
    {
        Json::FastWriter fastWriter2;
        std::string output2 = fastWriter2.write(root[i]["to"]);
        std ::cout << output2.substr(1, output2.size() - 3) << " " << k << std ::endl;
        if (root[i]["seen"] == false && k == output2.substr(1, output2.size() - 3))
        {
            Json::FastWriter fastWriter;
            std ::cout << "Ba uite ca ai!" << std ::endl;
            std::string output = fastWriter.write(root[i]["from"]);
            Json::FastWriter fastWriter1;
            std::string output1 = fastWriter1.write(root[i]["message"]);
            result += output.substr(0, output.size() - 1) + " : " + output1.substr(0, output1.size() - 1) + " \n ";
        }
    }
    file.close();
    if (result == "")
        result = "empty";
    return result;
}

void replay_to(char *to_user, char *msg)
{
    add_history(msg, users[count_user - 1].username_on, to_user);
    std ::cout << "Aici e o problema !" << std ::endl;

    Json::Value root;
    std::ifstream file("conv.json");
    file >> root;

    file.close();
    for (int i = 0; i < root.size(); i++)
    {
        Json::FastWriter fastWriter2;
        std::string output2 = fastWriter2.write(root[i]["to"]);

        Json::FastWriter fastWriter4;
        std::string output4 = fastWriter4.write(root[i]["from"]);

        if ((output4.substr(1, output4.size() - 3) == to_user) && (output2.substr(1, output2.size() - 3) == users[count_user - 1].username_on) and root[i]["seen"] == false)
        {
            std ::cout << root[i] << std ::endl;
            //   Json :: Value clear(root[i]["seen"]);
            root[i]["seen"] = true;
            std ::cout << "ROOT are valoare : " << root[i]["seen"] << std ::endl;
            std ::cout << root[i] << std ::endl;
        }
        std::cout << (output4.substr(1, output4.size() - 3) == to_user) << " " << (output2.substr(1, output2.size() - 3) == users[count_user - 1].username_on) << std::endl;
        std::cout << output4.substr(1, output4.size() - 3) << " " << to_user << " " << output2.substr(1, output2.size() - 3) << " " << users[count_user - 1].username_on << std::endl;
    }

    std ::ofstream fout("conv.json");
    Json::StyledWriter writer;
    std ::string strJson = writer.write(root);
    fout << strJson;
    fout.close();
}

void testing()
{
    Json::Value root;
    std::ifstream file("conv.json");
    file >> root;

    std ::string result;
    //  std :: cout<<"aici in unseen!" << std :: endl;
    // std :: cout << root.size()<< std :: endl;
    for (int i = 0; i < root.size(); i++)
    {
        std ::cout << root[i]["from"] << " " << root[i]["to"] << " " << root[i]["message"] << " " << root[i]["seen"] << std ::endl;
    }
    file.close();
}