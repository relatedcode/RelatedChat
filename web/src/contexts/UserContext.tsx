import { useQuery, useSubscription } from "@apollo/client";
import * as queries from "graphql/queries";
import * as subscriptions from "graphql/subscriptions";
import useAuth from "hooks/useAuth";
import { UserContext } from "lib/context";
import { useEffect, useState } from "react";

export const UserProvider = ({ children }: any) => {
  const { user: authUser } = useAuth();

  const { data } = useQuery(queries.GET_USER, {
    variables: { objectId: authUser?.uid },
    skip: !authUser?.uid,
  });
  const { data: dataPush } = useSubscription(subscriptions.USER, {
    variables: { objectId: authUser?.uid },
    skip: !authUser?.uid,
  });

  const [user, setUser] = useState(null);

  useEffect(() => {
    if (data) {
      setUser(data.getUser);
    }
  }, [data]);

  useEffect(() => {
    if (dataPush) {
      setUser(dataPush.onUpdateUser);
    }
  }, [dataPush]);

  return (
    <UserContext.Provider
      value={{
        user: authUser,
        userdata: user,
      }}
    >
      {children}
    </UserContext.Provider>
  );
};
