export function setLoginToken(token: string) {
  document.cookie = `token=${token}`;
  document.cookie = `isLogged=true`;

  return "/?authorized";
}
