using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MoveA : MonoBehaviour
{
    [Serializable]
    public class CaughtObject
    {
        public Rigidbody2D rigidbody;
        public Collider2D collider;
        public bool inContact;
        public bool checkedThisFrame;
    }
    public Rigidbody2D platformRigidbody;
    public ContactFilter2D contactFilter;

    protected List<CaughtObject> m_CaughtObjects = new List<CaughtObject>(128);
    protected ContactPoint2D[] m_ContactPoints = new ContactPoint2D[20];
    protected Collider2D m_Collider;
    [SerializeField] private float speedMove = 0.5f;
    [SerializeField] private bool isMoveRight = true;
    // Update is called once per frame
    private void Awake()
    {
        if (m_Collider == null)
            m_Collider = GetComponent<Collider2D>();
    }
    void Update()
    {
        float direct = isMoveRight == true ? 1f : -1;
        transform.position += transform.right * speedMove * direct * Time.deltaTime;
    }
    private void FixedUpdate()
    {
        for (int i = 0, count = m_CaughtObjects.Count; i < count; i++)
        {
            CaughtObject caughtObject = m_CaughtObjects[i];
            caughtObject.inContact = false;
            caughtObject.checkedThisFrame = false;
        }
        CheckRigidbodyContacts(platformRigidbody);
        bool checkAgain;
        do
        {
            for (int i = 0, count = m_CaughtObjects.Count; i < count; i++)
            {
                CaughtObject caughtObject = m_CaughtObjects[i];

                if (caughtObject.inContact)
                {
                    if (!caughtObject.checkedThisFrame)
                    {
                        CheckRigidbodyContacts(caughtObject.rigidbody);
                        caughtObject.checkedThisFrame = true;
                    }
                }
                //Some cases will remove all contacts (collider resize etc.) leading to loosing contact with the platform
                //so we check the distance of the object to the top of the platform.
                if (!caughtObject.inContact)
                {
                    Collider2D caughtObjectCollider = m_CaughtObjects[i].collider;

                    //check if we are aligned with the moving paltform, otherwise the yDiff test under would be true even if far from the platform as long as we are on the same y level...
                    bool verticalAlignement = (caughtObjectCollider.bounds.max.x > m_Collider.bounds.min.x) && (caughtObjectCollider.bounds.min.x < m_Collider.bounds.max.x);
                    if (verticalAlignement)
                    {
                        float yDiff = m_CaughtObjects[i].collider.bounds.min.y - m_Collider.bounds.max.y;

                        if (yDiff > 0 && yDiff < 0.05f)
                        {
                            caughtObject.inContact = true;
                            caughtObject.checkedThisFrame = true;
                        }
                    }
                }
            }

            checkAgain = false;

            for (int i = 0, count = m_CaughtObjects.Count; i < count; i++)
            {
                CaughtObject caughtObject = m_CaughtObjects[i];
                if (caughtObject.inContact && !caughtObject.checkedThisFrame)
                {
                    checkAgain = true;
                    break;
                }
            }
        }
        while (checkAgain);
    }
    void CheckRigidbodyContacts(Rigidbody2D rb)
    {
        int contactCount = rb.GetContacts(contactFilter, m_ContactPoints);

        for (int j = 0; j < contactCount; j++)
        {
            ContactPoint2D contactPoint2D = m_ContactPoints[j];
            Rigidbody2D contactRigidbody = contactPoint2D.rigidbody == rb ? contactPoint2D.otherRigidbody : contactPoint2D.rigidbody;
            int listIndex = -1;

            for (int k = 0; k < m_CaughtObjects.Count; k++)
            {
                if (contactRigidbody == m_CaughtObjects[k].rigidbody)
                {
                    listIndex = k;
                    break;
                }
            }

            if (listIndex == -1)
            {
                if (contactRigidbody != null)
                {

                    if (contactRigidbody.bodyType == RigidbodyType2D.Static && contactRigidbody != platformRigidbody)
                    {

                        float dot = Vector2.Dot(contactPoint2D.normal, Vector2.up);
                        if (dot > 0.8f)
                        {
                            CaughtObject newCaughtObject = new CaughtObject
                            {
                                rigidbody = contactRigidbody,
                                collider = contactRigidbody.GetComponent<Collider2D>(),
                                inContact = true,
                                checkedThisFrame = false
                            };
                            m_CaughtObjects.Add(newCaughtObject);
                        }
                    }
                }
            }
            else
            {
                m_CaughtObjects[listIndex].inContact = true;
            }
        }
    }
}
