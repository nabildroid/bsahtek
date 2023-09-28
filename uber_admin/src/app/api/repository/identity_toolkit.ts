import { auth } from "google-auth-library";
const keys = JSON.parse(process.env.GOOGLE_ADMIN_FIREBASE!);

const client = auth.fromJSON(keys);

(client as any).scopes = [
  "https://www.googleapis.com/auth/cloud-identity.groups",
  "https://www.googleapis.com/auth/cloud-identity.groups.readonly",
  "https://www.googleapis.com/auth/cloud-identity.groups",
  "https://www.googleapis.com/auth/cloud-identity",
  "https://www.googleapis.com/auth/cloud-platform",
];

client.projectId = process.env.GOOGLE_PROJECT_ID!;

type Groups = {
  name: string;
  groupKey: {
    id: string;
  };
  displayName: string;
}[];

export async function listGroups(customerID: string) {
  const response = await client.request<{ groups: Groups }>({
    url: "https://cloudidentity.googleapis.com/v1/groups",
    params: {
      parent: "customers/" + customerID,
    },
  });

  return response.data.groups;
}

export async function checkMembership(groupName: string, memberEmail: string) {
  try {
    const response = await client.request({
      url: "https://cloudidentity.googleapis.com/v1/" + groupName + "/memberships:lookup",
      params: {
        ["memberKey.id"]: memberEmail,
      },
    });

    return true;
  } catch (e) {
    console.log(e);
    return false;
  }
}
