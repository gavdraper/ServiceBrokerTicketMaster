using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BrokerLib
{
    public class Broker
    {
        public SqlConnection cnn;
        public SqlTransaction tran;
        public SqlCommand cmd;

        public Broker(string connectionString)
        {
            cnn = new SqlConnection(connectionString);
            cnn.Open();
        }

        public void Send(Guid dialogHandle, string msg, string msgType)
        {
            // Get the context command
            SqlCommand cmd = cnn.CreateCommand();
            cmd.Transaction = tran;

            // Add dialog handle
            SqlParameter paramDialogHandle = new SqlParameter("@dh", SqlDbType.UniqueIdentifier);
            paramDialogHandle.Value = dialogHandle;
            cmd.Parameters.Add(paramDialogHandle);

            // Add message
            SqlParameter paramMsg = new SqlParameter("@msg", SqlDbType.NVarChar, msg.Length);
            paramMsg.Value = msg;
            cmd.Parameters.Add(paramMsg);

            // Build the SEND command
            cmd.CommandText = "SEND ON CONVERSATION @dh " +
                "MESSAGE TYPE [" + msgType + "]" +
                "(@msg)";

            try
            {
                cmd.ExecuteNonQuery();

                //Console.WriteLine("Sent message: " + msg);
            }
            catch (Exception e)
            {
                //Console.WriteLine("SEND failed " + e.Message);
            }
        }

        public void Receive(string queueName, out string msgType, out string msg, out Guid ConversationGroup, out Guid dialogHandle)
        {
            //default return values
            msgType = null;
            msg = null;
            ConversationGroup = Guid.Empty;
            dialogHandle = Guid.Empty;

            // Get the context command
            cmd = cnn.CreateCommand();
            cmd.Transaction = tran;

            // Get output msgtype
            SqlParameter paramMsgType = new SqlParameter("@msgtype", SqlDbType.NVarChar, 256);
            paramMsgType.Direction = ParameterDirection.Output;
            cmd.Parameters.Add(paramMsgType);

            // Get output msg
            SqlParameter paramMsg = new SqlParameter("@msg", SqlDbType.NVarChar, 4000);
            paramMsg.Direction = ParameterDirection.Output;
            cmd.Parameters.Add(paramMsg);

            // Get output si
            SqlParameter paramConversationGroup = new SqlParameter("@cg", SqlDbType.UniqueIdentifier);
            paramConversationGroup.Direction = ParameterDirection.Output;
            cmd.Parameters.Add(paramConversationGroup);

            // Get output dh
            SqlParameter paramDialogHandle = new SqlParameter("@dh", SqlDbType.UniqueIdentifier);
            paramDialogHandle.Direction = ParameterDirection.Output;
            cmd.Parameters.Add(paramDialogHandle);

            // Build the Receive command
            cmd.CommandText = "WAITFOR (RECEIVE TOP(1)  @msgtype = message_type_name, " +
                "@msg = message_body, " +
                "@cg = conversation_group_id, " +
                "@dh = conversation_handle " +
                "FROM [" + queueName + "]) " +
                ", TIMEOUT 5000";

            try
            {
                cmd.ExecuteNonQuery();

                if (!(paramMsgType.Value is DBNull))
                {
                    msgType = (string)paramMsgType.Value;
                    msg = (string)paramMsg.Value;
                    ConversationGroup = (System.Guid)paramConversationGroup.Value;
                    dialogHandle = (System.Guid)paramDialogHandle.Value;
                }

                //Console.WriteLine("Received message: " + msg);
            }
            catch (Exception e)
            {
                //Console.WriteLine("RECEIVE failed " + e.Message);
            }
        }

        public void EndDialog(Guid dialogHandle)
        {
            // Get the context command
            SqlCommand cmd = cnn.CreateCommand();
            cmd.Transaction = tran;

            // Add dialog handle
            SqlParameter paramDialogHandle = new SqlParameter("@dh", SqlDbType.UniqueIdentifier);
            paramDialogHandle.Value = dialogHandle;
            cmd.Parameters.Add(paramDialogHandle);

            // Build the SEND command
            cmd.CommandText = "END CONVERSATION @dh ";

            try
            {
                cmd.ExecuteNonQuery();

                //	Console.WriteLine("END DIALOG called...");
            }
            catch (Exception e)
            {
                //	Console.WriteLine("END CONVERSATION failed " + e.Message);
            }
        }
    }
}
